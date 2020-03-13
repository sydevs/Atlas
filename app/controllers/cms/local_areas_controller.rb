class CMS::LocalAreasController < CMS::ApplicationController
  include AutocompleteAPI

  prepend_before_action { @model = LocalArea }

  def create
    super parameters
  end

  def update
    super parameters
  end

  def autocomplete
    authorize LocalArea
    data = {
      language: I18n.locale,
      sessiontoken: session.id,
    }

    if params[:place_id].present?
      data[:placeid] = params[:place_id]
      result = AutocompleteAPI.fetch_area(data)
    else
      data[:components] = "country:#{params[:country]}" if params[:country].present?
      data[:input] = params[:query]
      result = AutocompleteAPI.predict(data)
    end

    if result
      render json: result
    else
      render json: {}, status: 404
    end
  end

  private

    def parameters
      params.fetch(:local_area, {}).permit(
        :name, :identifier, :country_code, :province_code,
        :latitude, :longitude, :radius, :restriction
      )
    end

end
