class Mail::LocalAreasController < Mail::ApplicationController

  before_action :fetch_local_area

  def summary
    summary_period = RegionMailer::SUMMARY_PERIOD
    @subject = I18n.translate('mail.region.summary.subject', region: @region.name)

    @start_of_period = summary_period.ago.beginning_of_week
    @end_of_period = @start_of_period + summary_period
    @end_of_period = Time.now # For testing
    query = ['events.created_at >= ? AND events.created_at <= ?', @start_of_period, @end_of_period]

    @new_events = @region.events.publicly_visible.where(*query)
    @expiring_events = @region.events.needs_urgent_review
    @recently_expired_events = @region.events.recently_expired

    @stats = {
      active_events: @region.events.publicly_visible.count,
      new_registrations: @region.associated_registrations.since(summary_period.ago).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
    render 'mail/regions/summary'
  end

  private

    def fetch_local_area
      if params[:local_area_id]
        @region = LocalArea.find(params[:local_area_id])
      else
        @region = LocalArea.order('RANDOM()').first
      end
    end

end
