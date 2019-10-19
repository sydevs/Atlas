class ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  include Pundit
  include Geokit::Geocoders

  layout -> { action_name == 'map' ? 'map' : 'admin' }
  helper_method :current_user

  def about
  end
  
  def map
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    location = IpGeocoder.geocode(request.remote_ip)
    if location.success
      @location = {
        lat: location.lat,
        lng: location.lng
      }
    else
      # defaults to city of london for now
      @location = {
        lat: 51.505, 
        lng: -0.09
      }
    end
    @venues = Venue.all
    @events = Event.joins(:venue).within(500, :origin => [@location[:lat], @location[:lng]])
  end

  def statistics
  end

  protected

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end
  
end
