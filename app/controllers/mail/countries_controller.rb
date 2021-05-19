class Mail::CountriesController < Mail::ApplicationController

  before_action :fetch_country

  SUMMARY_PERIOD = 2.weeks

  def summary
    country_label = CountryDecorator.get_short_label(@country.country_code)
    @subject = I18n.translate('mail.country.summary.subject', country: country_label)

    @start_of_period = SUMMARY_PERIOD.ago.beginning_of_week
    @end_of_period = @start_of_period + SUMMARY_PERIOD
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]
    managed_records_query = ['managed_records.created_at >= ? AND managed_records.created_at <= ?', @start_of_period, @end_of_period]

    @new_provinces = @country.provinces.where(*query)
    @new_local_areas = @country.local_areas.where(*query)
    @new_province_managers = @country.province_manager_records.where(*managed_records_query).joins(:manager)
    @new_local_area_managers = @country.local_area_manager_records.where(*managed_records_query).joins(:manager)
    @inactive_provinces = @country.provinces.inactive_since(SUMMARY_PERIOD.ago)
    @inactive_local_areas = @country.local_areas.inactive_since(SUMMARY_PERIOD.ago)

    @stats = {
      active_regions: @country.provinces.active_since(SUMMARY_PERIOD.ago).count,
      active_events: @country.events.publicly_visible.count,
      new_registrations: @country.associated_registrations.since(SUMMARY_PERIOD.ago).count,
    }

    @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
  end

  private

    def fetch_country
      if params[:country_id]
        @country = Country.find(params[:country_id])
      else
        @country = Country.order('RANDOM()').first
      end
    end

end
