class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!

  def show
    @api_endpoint = api_endpoint
    @preferred_language = params[:language]
    I18n.locale = params[:locale]

    if params[:event]
      event = Event.find(params[:event])
      @location = { latitude: event.latitude, longitude: event.longitude }
    elsif params[:q]
      @query = params[:q]
    else
      @location = geocoded_location
    end

    render 'map/show'
  end

  private

    def api_endpoint
      scope = nil

      if params[:area]
        scope = LocalArea.find_by_identifier(params[:area])
      elsif params[:province]
        scope = Province.find_by_province_code(params[:province])
      elsif params[:country]
        scope = Country.find_by_country_code(params[:country])
      end

      if scope
        url_for([:api, scope, :events, format: :json])
      else
        api_events_url(format: :json)
      end
    end

    def geocoded_location
      location = IpGeocoder.geocode(request.remote_ip)
      return { latitude: location.lat, longitude: location.lng } if location.success

      { latitude: 51.505, longitude: -0.09 } # Default to london for now
    end

    def set_cors!
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end
