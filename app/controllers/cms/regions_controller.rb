class CMS::RegionsController < CMS::ApplicationController

  prepend_before_action { @model = Region }

  def new
    super osm_id: params[:osm_id]
    @record.fetch_geo_data! unless params[:osm_id] == 'custom'
  end

  def create
    super parameters
  end

  def edit
    super osm_id: params[:osm_id]
    @record.fetch_geo_data! unless params[:osm_id] == 'custom'
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:region, {}).permit(:country_code, :name, :osm_id, :geojson, :bounds, :translations)
    end

end
