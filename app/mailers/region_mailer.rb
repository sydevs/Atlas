class RegionMailer < ApplicationMailer

  SUMMARY_PERIOD = 1.week
  include Summary

  default template_path: 'mail/regions'
  layout 'mail/admin'

  def summary
    setup
    last_summary_email_sent_at = @region.summary_email_sent_at || 1.year.ago
    cooldown_interval = ENV['TEST_EMAILS'] ? 1.day : SUMMARY_PERIOD - 1.day
    if params[:test] || last_summary_email_sent_at < cooldown_interval.ago
      puts "[MAIL] Sending summary email for #{@region.label}"
    else
      puts "[MAIL] Skip sending summary for #{@region.label}"
      return
    end
    
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
      new_registrations: 100, # @region.associated_registrations.since(SUMMARY_PERIOD.ago).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h

    if @region.is_a?(Province)
      label = ProvinceDecorator.get_name(@region.province_code, @region.country.country_code)
    elsif @region.try(:country_code)
      label = "#{@region.name}, #{CountryDecorator.get_short_label(@region.country_code)}"
    else
      label = @region.name
    end

    subject = I18n.translate('mail.region.summary.subject', region: label)
    managers = params[:test] ? @region.managers.limit(1) : @region.managers
    managers.each do |manager|
      create_session! manager
      mail(to: manager.email, subject: subject)
      puts "[MAIL] Sent summary for #{@region.label} to #{manager.name}"
    end

    @region.update_column(:summary_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @region = params[:region] || params[:record]
    end

end
