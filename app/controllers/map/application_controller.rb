class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!
  before_action :set_location!

  def show
    render 'map/show'
  end

  private

    def set_location!
      @location = begin
        location = IpGeocoder.geocode(request.remote_ip)
        return { latitude: location.lat, longitude: location.lng } if location.success

        { latitude: 51.505, longitude: -0.09 }
      end
    end

    def set_cors!
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end
