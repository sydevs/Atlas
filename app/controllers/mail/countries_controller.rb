class Mail::CountriesController < Mail::ApplicationController

  before_action :fetch_country

  def summary
    summary_period = CountryMailer::SUMMARY_PERIOD
    country_label = CountryDecorator.get_short_label(@country.country_code)
    @subject = I18n.translate('mail.country.summary.subject', country: country_label)

    @start_of_period = summary_period.ago.beginning_of_week
    @end_of_period = @start_of_period + summary_period
    @end_of_period = Time.now # For testing
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]
    managed_records_query = ['managed_records.created_at >= ? AND managed_records.created_at <= ?', @start_of_period, @end_of_period]

    @new_regions = @country.regions.where(*query)
    @new_areas = @country.areas.where(*query)
    @new_region_managers = @country.region_manager_records.where(*managed_records_query).joins(:manager)
    @new_area_managers = @country.area_manager_records.where(*managed_records_query).joins(:manager)
    @inactive_regions = @country.regions.inactive_since(summary_period.ago)
    @inactive_areas = @country.areas.inactive_since(summary_period.ago)

    @stats = {
      active_regions: @country.regions.active_since(summary_period.ago).count,
      active_events: @country.events.publicly_visible.count,
      new_registrations: @country.associated_registrations.since(summary_period.ago).count,
    }

    @old_stats = @stats
    # @old_stats = @stats.map { |key, value| [key, (value * rand(0.7..1.5)).to_i] }.to_h
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
