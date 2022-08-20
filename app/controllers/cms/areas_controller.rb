class CMS::AreasController < CMS::ApplicationController
  include GoogleMapsAPI

  prepend_before_action { @model = Area }

  def new
    if @context.is_a?(Region)
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
    redirect_to [:cms, @record.parent, :areas]
  end

  def geocode args = {}
    authorize @record || @model
    args.merge!({
      language: I18n.locale,
      sessiontoken: session.id,
      placeid: params[:place_id],
    })

    result = GoogleMapsAPI.fetch_area(args)
    puts "RESULT #{result.inspect}"
    render json: result, status: result ? 200 : 404
  end

  private

    def parameters
      params.fetch(:area, {}).permit(
        :name, :identifier, :country_code, :province_code,
        :latitude, :longitude, :radius, :restriction
      )
    end

end
