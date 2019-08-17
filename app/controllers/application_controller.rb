class ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  layout -> { action_name == 'map' ? 'map' : 'admin' }
  helper_method :current_user

  # before_action :require_login!, except: %i[map]
  before_action :allow_embed, only: %i[map]
  protect_from_forgery with: :exception

  def map
    @venues = Venue.all
    @events = Event.all
  end

  def dashboard
  end

  def statistics
  end

  protected

    def allow_embed
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end
  
    def require_login!
      return if current_user

      save_passwordless_redirect_location! Manager
      redirect_to root_path, flash: { error: 'You are not logged in!' }
    end

end
