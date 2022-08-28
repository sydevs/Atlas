class PlaceMailer < ApplicationMailer

  SUMMARY_PERIOD = 1.week
  include Summary

  default template_path: 'mail/places'
  layout 'mail/admin'

  def summary
    setup
    last_summary_email_sent_at = @place.summary_email_sent_at || 1.year.ago
    return unless @manager.notifications.place_summary?
    return if !params&.dig(:test) && last_summary_too_soon?(last_summary_email_sent_at)
    
    @start_of_period = SUMMARY_PERIOD.ago.beginning_of_week
    @end_of_period = @start_of_period + SUMMARY_PERIOD
    @end_of_period = Time.now
    query = { created_at: @start_of_period..@end_of_period }

    @new_events = @place.events.publicly_visible.where(query)
    @expiring_events = @place.events.needs_urgent_review
    @expired_events = @place.events.expired
    @inactive_areas = @place.areas.inactive_since(SUMMARY_PERIOD.ago) if @place.is_a?(Region)

    @stats = {
      active_events: @place.events.publicly_visible.count,
      new_registrations: @place.associated_registrations.since(SUMMARY_PERIOD.ago).count,
    }

    @old_stats = @stats
    # @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h

    if @place.try(:country_code)
      label = "#{@place.name}, #{CountryDecorator.get_short_label(@place.country_code)}"
    else
      label = @place.name
    end

    subject = I18n.translate('mail.place.summary.subject', place: label)
    create_session! @manager
    mail(to: @manager.email, subject: subject)
    puts "[MAIL] Sent summary for #{@place.label} to #{@manager.name}"

    @place.update_column(:summary_email_sent_at, Time.now) unless params[:test]
  end

  private

    def setup
      @place = params[:place] || params[:record]
      @manager = params[:manager]
      create_session!
    end

end
