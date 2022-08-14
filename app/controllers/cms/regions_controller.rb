class CMS::RegionsController < CMS::ApplicationController

  prepend_before_action { @model = Region }

  def new
    if params[:osm_id]
      super osm_id: params[:osm_id]
      @record.fetch_geo_data! unless @record.custom_geodata?
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
      @record.fetch_geo_data! unless @record.custom_geodata?
    else
      super
    end
  end

  def update
    super parameters
  end

  private

    def parameters
      parameters = params.fetch(:region, {}).permit(:country_code, :name, :osm_id, :geojson, :bounds, :translations)
      GeoData.parse_params(parameters)
    end

end
