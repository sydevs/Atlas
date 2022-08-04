class CMS::VenuesController < CMS::ApplicationController
  include GeocodeAPI

  prepend_before_action { @model = Venue }

  def new
    if @context.is_a?(Area)
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
    
    if @record.valid? && @context.is_a?(Area) && !@context.contains?(@record)
      authorize Area, :new?
      @record.errors.add(:base, I18n.translate('cms.messages.venue.out_of_bounds', area: @context.name))
      render 'cms/views/new'
    else
      super parameters
    end
  end

  def update
    super parameters
  end

  def geosearch
    super({
      types: 'street_address|premise|subpremise|room|place_of_worship',
      components: ("country:#{params[:country]}" if params[:country].present?),
    })
  end

  def geocode args = {}
    authorize @record || @model
    args.merge!({
      language: I18n.locale,
      sessiontoken: session.id,
      placeid: params[:place_id],
    })

    result = GoogleMapsAPI.fetch_place(args)
    puts "RESULT #{result.inspect}"
    render json: result, status: result ? 200 : 404
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
