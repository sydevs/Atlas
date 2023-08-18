class Info::ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  helper_method :current_user
  before_action :set_locale!

  def index
  end

  def about
  end

  def privacy
    render "info/privacy/privacy.#{I18n.locale}"
  end

  def statistics
    @events_data = Country.joins(:events).select('countries.country_code, count(events.id) as count').group('countries.country_code, countries.name').map { |c| [ c.country_code, c.count ] }.to_h

    recent_month_names = 5.downto(1).collect do |n| 
      Date.parse(Date::MONTHNAMES[n.months.ago.month]).strftime('%b')
    end

    registration_data = {}
    registration_data["World"] = Registration.since(6.months.ago).group_by_month.count.map { |k, v| [k.strftime("%b"), v] }.to_h
    Country.order_by_registrations.limit(10).map do |country|
      registration_data[country.name] = country.associated_registrations.since(6.months.ago).group_by_month.count.map { |k, v| [k.strftime("%b"), v] }.to_h
      registration_data[country.name]['total'] = registration_data[country.name].values.sum
    end
    
    @registrations_data = {
      labels: recent_month_names,
      series: registration_data.map do |name, monthly_registrations|
        {
          name: name,
          data: recent_month_names.map { |m| monthly_registrations[m] || 0 },
        }
      end
    }

    @country_registrations_data = {
      labels: registration_data.map { |name, registrations| "#{name} (#{registrations['total']})" if name != "World" }.compact,
      series: registration_data.map do |name, registrations|
        print "check", name
        if name != "World"
          {
            name: name,
            value: registrations['total'],
          }
        end
      end.compact
    }
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def set_locale!
      I18n.locale = params[:locale]&.to_sym || :en
    end

end
