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
      parameters = params.fetch(:country, {}).permit(:name, :country_code, :osm_id, :geojson, :bounds, :translations, :canonical_domain, :default_language_code, :enable_regions, :enable_custom_regions)
      GeoData.parse_params(parameters)
    end

end
