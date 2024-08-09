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
      parameters = params.fetch(:country, {}).permit(
        :name, :country_code, :osm_id, :geojson, :bounds,
        :translations, :default_language_code, :enable_regions, :enable_custom_regions,
        :mailing_list_service, :mailing_list_api_key, :mailing_list_list_id,
      )
      GeoData.parse_params(parameters)
    end

end
