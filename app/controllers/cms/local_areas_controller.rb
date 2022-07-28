class CMS::LocalAreasController < CMS::ApplicationController
  include GoogleMapsAPI

  prepend_before_action { @model = LocalArea }

  def new
    if @context.is_a?(Province)
      super country_code: @context.country_code
    else
      super
    end
  end

  def create
    super parameters
  end

  def update
    super parameters
  end

  def destroy
    authorize @record
    @record.destroy

    flash[:success] = translate('cms.messages.successfully_deleted', resource: @model.model_name.human.titleize)
    redirect_to [:cms, @record.parent, :regions]
  end

  def autocomplete
    authorize LocalArea
    data = {
      language: I18n.locale,
      sessiontoken: session.id,
    }

    if params[:place_id].present?
      data[:placeid] = params[:place_id]
      result = GoogleMapsAPI.fetch_area(data)
    else
      data[:components] = "country:#{params[:country]}" if params[:country].present?
      data[:input] = params[:query]
      result = GoogleMapsAPI.predict(data)
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
