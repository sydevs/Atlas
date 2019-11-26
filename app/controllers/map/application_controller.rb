class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!

  def show
    I18n.locale = params[:locale]

    @query = params[:q]
    @map_config = {
      api: api_endpoint,
      language: params[:language],
      token: ENV['MAPBOX_ACCESSTOKEN']
    }

    set_jbuilder_params!
    render 'map/show'
  end

  private

    def set_jbuilder_params!
      if params[:event]
        @records = [Event.find(params[:event])]
      elsif scope
        @records = scope.events.published
      else
        @records = Event.joins(:venue).within(50, origin: geocoded_coordinates)
      end

      @model = Event
    end

    def scope
      @scope ||= begin
        scope = nil

        if params[:area]
          scope = LocalArea.find_by_identifier(params[:area])
        elsif params[:province]
          scope = Province.find_by_province_code(params[:province])
        elsif params[:country]
          scope = Country.find_by_country_code(params[:country])
        end
      end
    end

    def api_endpoint
      if scope
        url_for([:api, scope, :events, format: :json])
      else
        api_events_url(format: :json)
      end
    end

    def geocoded_coordinates
      location = IpGeocoder.geocode(request.remote_ip)
      return [ location.lat, location.lng ] if location.success

      [ 51.505, -0.09 ] # Default to london for now
    end

    def set_cors!
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end
