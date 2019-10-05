class ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  include Pundit

  layout -> { action_name == 'map' ? 'map' : 'admin' }
  helper_method :current_user

  def about
  end
  
  def map
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    @venues = Venue.all
    @events = Event.all
  end

  def statistics
  end

  protected

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end
  
end
