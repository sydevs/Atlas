class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!

  def show
    I18n.locale = params[:locale] || :en

    if params[:venue_id]
      @venue = Venue.joins(:events).find(params[:venue_id])
    elsif params[:event_id]
      @event = Event.joins(:venue).find(params[:event_id])
      @venue = @event.venue
    end

    @config = {
      api: api_endpoint,
      language: params[:language],
      token: ENV['MAPBOX_ACCESSTOKEN'],
      restricted: [LocalArea, Province, Country].include?(scope.class).to_s,
    }

    @state = {
      query: params[:q],
      type: params[:type],
      latitude: params[:latitude],
      longitude: params[:longitude],
    }

    set_jbuilder_params!
    render 'map/show'
  end

  def privacy
    render 'map/privacy'
  end

  private

    def set_jbuilder_params!
      if scope
        @records = scope.includes(:events, events: :pictures).published
      else
        @records = Venue.includes(:events, events: :pictures).within(50, origin: coordinates)
      end

      @verbose = true
      @model = Venue
    end

    def scope
      @scope ||= begin
        scope = nil

        if params[:venue] || params[:event]
          scope = @venue
        elsif params[:area]
          scope = LocalArea.find_by_identifier(params[:area])
        elsif params[:province]
          scope = Province.find_by_province_code(params[:province])
        elsif params[:country]
          scope = Country.find_by_country_code(params[:country])
        end

        scope = scope.published if scope.respond_to?(:published)
      end
    end

    def api_endpoint
      if scope
        url_for([:api, scope, :events, format: :json])
      else
        api_venues_url(format: :json)
      end
    end

    def coordinates
      return [ params[:latitude], params[:longitude] ] if params[:latitude].present? && params[:longitude].present?

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
