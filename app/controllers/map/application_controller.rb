class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!

  def show
    location = IpGeocoder.geocode(request.remote_ip)
    if location.success
      @location = {
        lat: location.lat,
        lng: location.lng,
      }
    else
      # defaults to city of london for now
      @location = {
        lat: 51.505,
        lng: -0.09,
      }
    end

    render 'map/show'
  end

  private

    def set_cors!
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end
