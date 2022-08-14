class CMS::CountriesController < CMS::ApplicationController

  prepend_before_action { @model = Country }

  def new
    if params[:osm_id]
      super osm_id: params[:osm_id]
      @record.fetch_geo_data!
    else
      super
    end
  end

  def create
    super parameters
  end

  def edit
    if params[:osm_id]
      super osm_id: params[:osm_id]
      @record.fetch_geo_data!
    else
      super
    end
  end

  def update
    super parameters
  end

  private

    def parameters
      parameters = params.fetch(:country, {}).permit(:name, :country_code, :osm_id, :geojson, :bounds, :translations, :default_language_code, :enable_regions, :enable_custom_regions)
      %i[bounds geojson translations].each do |key|
        parameters[key] = JSON.parse(parameters[key])
      end
      parameters
    end

end
