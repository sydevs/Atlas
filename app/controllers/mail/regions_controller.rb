class Mail::RegionsController < Mail::ApplicationController

  before_action :fetch_region

  def summary
    summary_period = PlaceMailer::SUMMARY_PERIOD
    @subject = I18n.translate('mail.place.summary.subject', place: @place.name)

    @start_of_period = summary_period.ago.beginning_of_week
    @end_of_period = @start_of_period + summary_period
    @end_of_period = Time.now # For testing
    @new_events = @place.events.publicly_visible.where(created_at: @start_of_period..@end_of_period)
    @expiring_events = @place.events.needs_urgent_review
    @expired_events = @place.events.expired
    @inactive_areas = @place.areas.inactive_since(summary_period.ago)

    @stats = {
      active_events: @place.events.publicly_visible.count,
      # new_registrations: @place.associated_registrations.since(summary_period.ago).count,
    }

    @old_stats = @stats
    # @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
    render 'mail/places/summary'
  end

  private

    def fetch_region
      if params[:region_id]
        @place = Region.find(params[:region_id])
      else
        @place = Region.reorder('RANDOM()').first
      end
    end

end
