class CMS::RegionsController < CMS::ApplicationController

  prepend_before_action { @model = Region }

  def new
    if params[:osm_id]
      super osm_id: params[:osm_id]
      @record.fetch_geo_data! unless params[:osm_id] == 'custom'
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
      @record.fetch_geo_data! unless params[:osm_id] == 'custom'
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
      %i[bounds geojson translations].each do |key|
        parameters[key] = JSON.parse(parameters[key])
      end
      parameters
    end

end
