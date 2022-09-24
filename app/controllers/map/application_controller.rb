class Map::ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  include Geokit::Geocoders
  layout 'map/application'
  before_action :setup_client!
  before_action :setup_config!

  def show
    render 'map/show'
  end
  
  def embed
    # response.headers["Expires"] = 1.day.from_now.httpdate
    # expires_in 1.day, public: true, must_revalidate: true

    render 'map/embed'
  end

  private

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

    def setup_config!
      I18n.locale = params[:locale]&.to_sym || :en
      @config = {
        token: ENV['MAPBOX_ACCESSTOKEN'],
        endpoint: api_graphql_url,
        locale: I18n.locale,
        search: !(params[:path] =~ /region|country/),
      }
  
      location = params[:country].present? ? Country.find_by_country_code(params[:country]) : @client&.location
      @config[:bounds] = location.client_bounds if location.present? && location.bounds.present?
      @config[:center] = coordinates unless @config[:bounds].present?
      @config.merge!(@client.config).merge!({
        location_type: @client.location_type.downcase,
        location_id: @client.location_id
      }) if @client.present?
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

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

end
