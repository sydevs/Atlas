class Mail::AreasController < Mail::ApplicationController

  before_action :fetch_area

  def summary
    summary_period = PlaceMailer::SUMMARY_PERIOD
    @subject = I18n.translate('mail.place.summary.subject', place: @place.name)

    @start_of_period = summary_period.ago.beginning_of_week
    @end_of_period = @start_of_period + summary_period
    @end_of_period = Time.now # For testing
    query = { created_at: @start_of_period..@end_of_period }

    @new_events = @place.events.publicly_visible.where(query)
    @expiring_events = @place.events.needs_urgent_review
    @expired_events = @place.events.expired

    @stats = {
      active_events: @place.events.publicly_visible.count,
      new_registrations: @place.associated_registrations.since(summary_period.ago).count,
    }

    @old_stats = @stats
    # @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
    render 'mail/places/summary'
  end

  private

    def fetch_area
      if params[:area_id]
        @place = Area.find(params[:area_id])
      else
        @place = Area.order('RANDOM()').first
      end
    end

end
