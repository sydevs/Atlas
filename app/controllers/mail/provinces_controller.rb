class Mail::ProvincesController < Mail::ApplicationController

  before_action :fetch_province

  def summary
    summary_period = PlaceMailer::SUMMARY_PERIOD
    province_label = ProvinceDecorator.get_name(@place.province_code, @place.country.country_code)
    @subject = I18n.translate('mail.place.summary.subject', place: province_label)

    @start_of_period = summary_period.ago.beginning_of_week
    @end_of_period = @start_of_period + summary_period
    @end_of_period = Time.now # For testing
    query = ['events.created_at >= ? AND events.created_at <= ?', @start_of_period, @end_of_period]

    @new_events = @place.events.publicly_visible.where(*query)
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

    def fetch_province
      if params[:province_id]
        @place = Province.find(params[:province_id])
      else
        @place = Province.reorder('RANDOM()').first
      end
    end

end
