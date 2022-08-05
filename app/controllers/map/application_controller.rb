class Map::ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  include Geokit::Geocoders
  layout 'map/application'
  before_action :setup_client!

  def show
    I18n.locale = params[:locale]&.to_sym || :en
    @list_type = params[:type] == 'online' ? 'online' : 'offline'
    @mode = 'map'

    if params[:venue_id]
      @venue = GraphqlAPI.venue(params[:venue_id])
      @mode = 'venue'
    elsif params[:event_id]
      @event = GraphqlAPI.event(params[:event_id])
      @mode = 'event'
      
      if @event['online']
        @list_type = 'online'
      else 
        @venue = @event['venue']
      end
    end

    @config = { token: ENV['MAPBOX_ACCESSTOKEN'] }

    country = Country.find_by_country_code(params[:country]) if params[:country].present?
    @config[:bounds] = country.bounds if country.present?

    unless @config[:bounds].present?
      @config.merge!({
        latitude: coordinates[0],
        longitude: coordinates[1],
      })
    end

    @config.merge!(@client.map_config) if @client
    @config[:language] ||= params[:language]

    render 'map/show'
  end

  def index
    I18n.locale = params[:locale]&.to_sym || :en
    @events = GraphqlAPI.events(online: params[:online])

    if params[:online]
      @language_codes = Event.online(params[:online]).distinct.pluck(:language_code) || []
    else
      @language_codes = Event.distinct.pluck(:language_code) || []
    end

    render 'map/index'
  end

  private

    def scope
      @scope ||= begin
        scope = nil

        if params[:venue] || params[:event]
          scope = @venue
        elsif params[:area]
          scope = Area.find_by_identifier(params[:area])
        elsif params[:region]
          scope = Region.find_by_province_code(params[:region])
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

    def coordinates
      @coordinates ||= begin
        if params[:latitude].present? && params[:longitude].present?
          [ params[:latitude], params[:longitude] ]
        else
          location = IpGeocoder.geocode(request.remote_ip)
          location.success ? [ location.lat, location.lng ] : [ 51.505, -0.09 ] # Default to london for now
        end
      end
    end

    def setup_client!
      @client = Client.find_by_public_key(params[:key])
      return if !params[:key].present?
      raise ActionController::RoutingError.new('Not Found') if @client.nil?

      headers['X-FRAME-OPTIONS'] = "ALLOW-FROM #{@client.domain}"
      headers['Access-Control-Allow-Origin'] = @client.domain
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

end
