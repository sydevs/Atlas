class API::CountriesController < API::ApplicationController

  def index
    @countries = decorate(Country.publicly_visible)
  end

  def show
    @country = decorate(Country.find(params[:id]))
  end

end
