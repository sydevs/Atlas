class API::CountriesController < API::ApplicationController

  def index
    country = Country.order_by_locale(I18n.locale || :en).order_by_events.includes(:regions, :areas)
    @countries = decorate(country)
  end

  def show
    begin
      !!Integer(params[:id])
      @country = decorate(Country.find(params[:id]))
    rescue ArgumentError, TypeError
      @country = decorate(Country.find_by_country_code(params[:id]&.upcase))
    end
  end

end
