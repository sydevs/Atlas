class Mail::ApplicationController < ActionController::Base

  layout 'mail/admin'

  include Passwordless::ControllerHelpers

  helper_method :current_user
  before_action :verify_admin!

  def summary
    @subject = I18n.translate('mail.summary.title')
    @start_of_month = (Date.today - 1.month).beginning_of_month
    @end_of_month = (Date.today - 1.month).end_of_month

    query = ['created_at >= ? AND created_at <= ?', @start_of_month, @end_of_month]
    @new_countries = Country.limit(5) #.where(*query)
    @new_country_managers = ManagedRecord.where(record_type: 'Country').joins(:manager).limit(5) #.where(*query)
    @new_access_keys = AccessKey.limit(5) #.where(*query)
    @stats = {
      active_countries: 3, #Manager.where(*query).count,
      active_events: 14, #Event.publicly_visible.count,
      new_registrations: 100, # Registration.where(*query).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
  end

  protected

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def verify_admin!
      return if current_user && current_user.administrator?

      raise ActionController::RoutingError.new('Not Found')
    end

end
