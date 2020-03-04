class Info::ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  helper_method :current_user

  def index
  end

  def about
  end

  def statistics
    @events_data = Country.joins(:events).select('countries.country_code, count(events.id) as count').group('countries.country_code').map { |c| [ c.country_code, c.count ] }.to_h

    recent_month_names = 5.downto(1).collect do |n| 
      Date.parse(Date::MONTHNAMES[n.months.ago.month]).strftime('%b')
    end
    
    monthly_registrations = Registration.since(6.months.ago).group_by_month.count.map { |k, v| [k.strftime("%b"), v] }.to_h
    @registrations_data = {
      labels: recent_month_names,
      series: [
        {
          name: 'monthly',
          data: recent_month_names.map { |m| monthly_registrations[m] || 0 },
        }
      ],
    }
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

end
