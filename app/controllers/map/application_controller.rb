class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!

  def show
    I18n.locale = params[:locale]&.to_sym || :en
    @mode = 'map'

    if params[:venue_id]
      @venue = Venue.joins(:events).find(params[:venue_id])
      @mode = 'venue'
    elsif params[:event_id]
      @event = Event.joins(:venue).find(params[:event_id])
      @venue = @event.venue
      @mode = 'event'
    end

    @config = {
      api: api_endpoint,
      language: params[:language],
      token: ENV['MAPBOX_ACCESSTOKEN'],
      restricted: [LocalArea, Province, Country].include?(scope.class).to_s,
    }

    @state = {
      label: params[:q],
      type: params[:type],
      latitude: params[:latitude] || @venue&.latitude,
      longitude: params[:longitude] || @venue&.longitude,
    }

    @state[:zoom] ||= 16 if @state[:latitude] && @state[:longitude]

    if params[:north] && params[:south] && params[:east] && params[:west]
      @state.merge!({
        north: params[:north],
        south: params[:south],
        east: params[:east],
        west: params[:west]
      })
    end

    set_jbuilder_params!
    render 'map/show'
  end

  def closest
    params.require(%i[latitude longitude])
    coordinates = [params[:latitude], params[:longitude]]

    query = Venue.publicly_visible.by_distance(origin: coordinates).where('venues.updated_at < ?', MapboxSync.last_synced_at)
    @venue = query.joins(:events).limit(1).first

    distance = @venue.distance_from(coordinates)
    @event = @venue.events.unscoped.first if distance < 8

    render 'cms/application/closest', format: :json
  end

  def privacy
    render 'map/privacy'
  end

  private

    def set_jbuilder_params!
      if scope
        @records = scope.includes(:events, events: :pictures)
      else
        @records = Venue.publicly_visible.includes(:events, events: :pictures).within(50, origin: coordinates)
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

        if scope.respond_to?(:publicly_visible)
          scope = scope.publicly_visible
        elsif scope.respond_to?(:published)
          scope = scope.published
        end

        scope
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
