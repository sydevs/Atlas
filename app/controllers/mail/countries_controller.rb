class Mail::CountriesController < Mail::ApplicationController

  before_action :fetch_country

  def summary
    country_label = CountryDecorator.get_short_label(@country.country_code)
    @subject = I18n.translate('mail.country.summary.subject', country: country_label)

    @start_of_period = 2.weeks.ago.beginning_of_week
    @end_of_period = @start_of_period + 2.weeks
    query = ['created_at >= ? AND created_at <= ?', @start_of_period, @end_of_period]

    @new_provinces = @country.provinces.limit(3) #.where(*query)
    @new_local_areas = @country.local_areas.limit(1) #.where(*query)
    @new_region_managers = ManagedRecord.where(record_type: ['Province', 'LocalArea']).joins(:manager).limit(5) #.where(*query)
    @inactive_provinces = @country.provinces.limit(2)
    @inactive_local_areas = @country.local_areas.limit(2)

    @stats = {
      active_regions: 3, #Manager.where(*query).count,
      active_events: 14, #Event.publicly_visible.count,
      new_registrations: 100, # Registration.where(*query).count,
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
