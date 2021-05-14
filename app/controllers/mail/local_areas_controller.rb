class Mail::LocalAreasController < Mail::ApplicationController

  before_action :fetch_local_area

  def summary
    @subject = I18n.translate('mail.region.summary.subject', region: @region.name)

    @start_of_period = 1.week.ago.beginning_of_week
    @end_of_period = @start_of_period + 1.week
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]

    @new_events = @region.events.reorder('RANDOM()').limit(3) #.publicly_visible.where(*query)
    @expiring_events = @region.events.reorder('RANDOM()').limit(5) #.needs_urgent_review
    @recently_expired_events = @region.events.reorder('RANDOM()').limit(4) #.recently_expired

    @stats = {
      active_events: 14, #@region.events.publicly_visible.count,
      new_registrations: 100, # Registration.where(*query).count,
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
