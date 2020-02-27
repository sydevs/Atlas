class CMS::VenuesController < CMS::ApplicationController
  include GeocodeAPI

  prepend_before_action { @model = Venue }

  def new
    if @context.is_a?(Province)
      super country_code: @context.country_code, province_code: @context.province_code
    elsif @context.is_a?(Country)
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

  def geocode
    authorize Venue

    result = GeocodeAPI.googlemaps({
      input: params[:query],
      language: I18n.locale,
    })

    if result
      render json: result
    else
      render json: {}, status: 404
    end
  end

  private

    def parameters
      params.fetch(:venue, {}).permit(
        :published,
        :name, :category, :latitude, :longitude, :place_id,
        :street, :city, :province_code, :country_code,
        manager: {}
      )
    end

end
