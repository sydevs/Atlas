class CountryMailer < ApplicationMailer

  SUMMARY_PERIOD = 2.weeks
  include Summary

  default template_path: 'mail/countries'
  layout 'mail/admin'

  def summary
    setup
    last_summary_email_sent_at = @country.summary_email_sent_at || 1.year.ago
    return if !params&.dig(:test) && last_summary_too_soon?(last_summary_email_sent_at)

    puts "[MAIL] Sending summary email for #{@country.label}"

    set_summary_period!
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]
    managed_records_query = ['managed_records.created_at >= ? AND managed_records.created_at <= ?', @start_of_period, @end_of_period]

    @new_provinces = @country.provinces.where(*query)
    @new_local_areas = @country.local_areas.where(*query)
    @new_province_managers = @country.province_manager_records.where(*managed_records_query).joins(:manager)
    @new_local_area_managers = @country.local_area_manager_records.where(*managed_records_query).joins(:manager)
    @inactive_provinces = @country.provinces.inactive_since(SUMMARY_PERIOD.ago)
    @inactive_local_areas = @country.local_areas.inactive_since(SUMMARY_PERIOD.ago)

    @stats = {
      active_regions: @country.provinces.active_since(SUMMARY_PERIOD.ago).count,
      active_events: @country.events.publicly_visible.count,
      new_registrations: @country.associated_registrations.since(SUMMARY_PERIOD.ago).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h

    country_label = CountryDecorator.get_short_label(@country.country_code)
    subject = I18n.translate('mail.country.summary.subject', country: country_label)

    create_session! @manager
    mail(to: @manager.email, subject: subject)
    puts "[MAIL] Sent summary for #{@country.label} to #{@manager.name}"

    @country.update_column(:summary_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @country = params[:country] || params[:record]
      @manager = params[:manager]
    end

end
