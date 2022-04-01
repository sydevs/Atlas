class RegionMailer < ApplicationMailer

  SUMMARY_PERIOD = 1.week
  include Summary

  default template_path: 'mail/regions'
  layout 'mail/admin'

  def summary
    setup
    last_summary_email_sent_at = @region.summary_email_sent_at || 1.year.ago
    return unless @manager.notifications.region_summary?
    return if !params&.dig(:test) && last_summary_too_soon?(last_summary_email_sent_at)
    
    @start_of_period = SUMMARY_PERIOD.ago.beginning_of_week
    @end_of_period = @start_of_period + SUMMARY_PERIOD
    @end_of_period = Time.now
    query = ['events.created_at >= ? AND events.created_at <= ?', @start_of_period, @end_of_period]

    @new_events = @region.events.publicly_visible.where(*query)
    @expiring_events = @region.events.needs_urgent_review
    @expired_events = @region.events.expired
    @inactive_local_areas = @region.local_areas.inactive_since(SUMMARY_PERIOD.ago) if @region.is_a?(Province)

    @stats = {
      active_events: @region.events.publicly_visible.count,
      new_registrations: @region.associated_registrations.since(SUMMARY_PERIOD.ago).count,
    }

    @old_stats = @stats
    # @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h

    if @region.is_a?(Province)
      label = ProvinceDecorator.get_name(@region.province_code, @region.country.country_code)
    elsif @region.try(:country_code)
      label = "#{@region.name}, #{CountryDecorator.get_short_label(@region.country_code)}"
    else
      label = @region.name
    end

    subject = I18n.translate('mail.region.summary.subject', region: label)
    create_session! @manager
    mail(to: @manager.email, subject: subject)
    puts "[MAIL] Sent summary for #{@region.label} to #{@manager.name}"

    @region.update_column(:summary_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @region = params[:region] || params[:record]
      @manager = params[:manager]
      create_session!
    end

end
