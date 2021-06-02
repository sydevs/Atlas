class ApplicationMailer < ActionMailer::Base

  SUMMARY_PERIOD = 1.month
  include Summary

  helper Mail::ApplicationHelper
  helper LocalizationHelper
  layout 'mail/admin'
  default template_path: 'mail/application'
  default from: 'Sahaj Atlas <contact@sydevelopers.com>'

  def summary
    last_summary_email_sent_at = Stash.get(:summary_email_sent_at) || 1.year.ago
    return if params&.dig(:test) || last_summary_too_soon?(last_summary_email_sent_at)

    puts "[MAIL] Sending summary for Sahaj Atlas"
    set_summary_period!
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]
    managed_records_query = ['managed_records.created_at >= ? AND managed_records.created_at <= ?', @start_of_period, @end_of_period]

    @new_countries = Country.where(*query)
    @new_country_managers = ManagedRecord.where(record_type: 'Country').joins(:manager).where(*managed_records_query)
    @new_access_keys = AccessKey.where(*query)
    @stats = {
      active_countries: Country.active_since(SUMMARY_PERIOD.ago).count,
      active_events: Event.publicly_visible.count,
      new_registrations: Registration.where(*query).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h

    subject = I18n.translate('mail.summary.title')
    managers = params && params[:test] ? Manager.administrators.limit(1) : Manager.administrators
    managers.each do |manager|
      # create_session! manager
      mail(to: manager.email, subject: subject)
      puts "[MAIL] Sent summary for Sahaj Atlas to #{manager.name}"
    end

    Stash.set(:summary_email_sent_at, Time.now) unless params && params[:test]
  end

  protected

    def create_session! manager = nil
      manager ||= @manager
      session = Passwordless::Session.new({
        authenticatable: manager,
        user_agent: 'Command Line',
        remote_addr: 'unknown',
      })

      session.save!
      @magic_link ||= send(Passwordless.mounted_as).token_sign_in_url(session.token)
      @template_link ||= "#{@magic_link}?destination_path="
    end

end
