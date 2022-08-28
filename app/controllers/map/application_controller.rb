class Map::ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  include Geokit::Geocoders
  layout 'map/application'
  before_action :setup_client!

  def show
    I18n.locale = params[:locale]&.to_sym || :en
    @config = { token: ENV['MAPBOX_ACCESSTOKEN'] }

    country = Country.find_by_country_code(params[:country]) if params[:country].present?
    @config[:bounds] = country.bounds if country.present?
    @config[:center] = coordinates unless @config[:bounds].present?
    @config[:search] = !(params[:path] =~ /region|country/)

    # @config.merge!(@client.map_config) if @client
    # @config[:language] ||= params[:language]

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
