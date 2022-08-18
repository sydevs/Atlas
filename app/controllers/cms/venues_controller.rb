class CMS::VenuesController < CMS::ApplicationController
  include GeocodeAPI

  prepend_before_action { @model = Venue }


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
        :published, :name, :address, :latitude, :longitude, :place_id,
      )
    end

end
