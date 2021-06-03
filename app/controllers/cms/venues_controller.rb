class CMS::VenuesController < CMS::ApplicationController
  include GeocodeAPI

  prepend_before_action { @model = Venue }

  def new
    if @context.is_a?(LocalArea)
      super country_code: @context.country_code, province_code: @context.province_code
    elsif @context.is_a?(Province)
      super country_code: @context.country_code, province_code: @context.province_code
    elsif @context.is_a?(Country)
      super country_code: @context.country_code
    else
      super
    end
  end

  def create
    @record = @scope.new(parameters)
    
    if @context.is_a?(LocalArea) && !@context.contains?(@record)
      authorize LocalArea, :new?
      @record.errors.add(:base, I18n.translate('cms.messages.venue.out_of_bounds', local_area: @context.name))
      render 'cms/views/new'
    else
      super parameters
    end
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

  # Unfortunately this doesn't return consistent address results, so this method is not currently used.
  def autocomplete
    authorize LocalArea
    data = {
      language: I18n.locale,
      sessiontoken: session.id,
    }

    if params[:place_id].present?
      data[:placeid] = params[:place_id]
      result = AutocompleteAPI.fetch_address(data)
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
      params.fetch(:venue, {}).permit(
        :published,
        :name, :category, :latitude, :longitude, :place_id,
        :street, :city, :province_code, :country_code, :postcode,
        manager: {}
      )
    end

end
