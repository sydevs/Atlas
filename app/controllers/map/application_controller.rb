class Map::ApplicationController < ActionController::Base

  include Geokit::Geocoders
  layout 'map/application'
  before_action :set_cors!

  def show
    I18n.locale = params[:locale]&.to_sym || :en
    @list_type = params[:type] || 'offline'
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

    @config = {
      language: params[:language],
      token: ENV['MAPBOX_ACCESSTOKEN'],
      latitude: coordinates[0],
      longitude: coordinates[1],
    }

    if params[:country] && Country.where(country_code: params[:country]).exists?
      @config[:country] = GraphqlAPI.country(params[:country])
    end

    render 'map/show'
  end

  def privacy
    render 'map/privacy'
  end

  private

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

    def set_cors!
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end
