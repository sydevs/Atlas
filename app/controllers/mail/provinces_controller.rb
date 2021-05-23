class Mail::ProvincesController < Mail::ApplicationController

  before_action :fetch_province

  def summary
    summary_period = RegionMailer::SUMMARY_PERIOD
    province_label = ProvinceDecorator.get_name(@region.province_code, @region.country.country_code)
    @subject = I18n.translate('mail.region.summary.subject', region: province_label)

    @start_of_period = summary_period.ago.beginning_of_week
    @end_of_period = @start_of_period + summary_period
    @end_of_period = Time.now # For testing
    query = ['events.created_at >= ? AND events.created_at <= ?', @start_of_period, @end_of_period]

    @new_events = @region.events.publicly_visible.where(*query)
    @expiring_events = @region.events.needs_urgent_review
    @recently_expired_events = @region.events.recently_expired
    @inactive_local_areas = @region.local_areas.inactive_since(summary_period.ago)

    @stats = {
      active_events: @region.events.publicly_visible.count,
      new_registrations: 100, # @region.associated_registrations.since(summary_period.ago).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
    render 'mail/regions/summary'
  end

  private

    def fetch_province
      if params[:province_id]
        @region = Province.find(params[:province_id])
      else
        @region = Province.reorder('RANDOM()').first
      end
    end

end
