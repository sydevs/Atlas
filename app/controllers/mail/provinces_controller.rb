class Mail::ProvincesController < Mail::ApplicationController

  before_action :fetch_province

  def summary
    province_label = ProvinceDecorator.get_name(@region.province_code, @region.country.country_code)
    @subject = I18n.translate('mail.region.summary.subject', region: province_label)

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

    def fetch_province
      if params[:province_id]
        @region = Province.find(params[:province_id])
      else
        @region = Province.reorder('RANDOM()').first
      end
    end

end
