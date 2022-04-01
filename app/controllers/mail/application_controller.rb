class Mail::ApplicationController < ActionController::Base

  layout 'mail/admin'

  include Passwordless::ControllerHelpers

  helper_method :current_user

  # This verification is no longer needed since the /mail routes are only available in development
  # before_action :verify_admin!

  SUMMARY_PERIOD = 1.month

  def summary
    summary_period = ApplicationMailer::SUMMARY_PERIOD
    @subject = I18n.translate('mail.summary.title')

    @start_of_period = summary_period.ago.beginning_of_month
    @end_of_period = summary_period.ago.end_of_month
    @end_of_period = Time.now # For testing
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]
    managed_records_query = ['managed_records.created_at >= ? AND managed_records.created_at <= ?', @start_of_period, @end_of_period]

    @new_countries = Country.where(*query)
    @new_country_managers = ManagedRecord.where(record_type: 'Country').joins(:manager).where(*managed_records_query)
    @new_clients = Client.where(*query)
    @stats = {
      active_countries: Country.active_since(summary_period.ago).count,
      active_events: Event.publicly_visible.count,
      new_registrations: Registration.where(*query).count,
    }

    @old_stats = @stats
    # @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
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
