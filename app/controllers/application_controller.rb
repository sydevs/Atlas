class ApplicationController < ActionController::Base

  layout -> { %w[index map].include?(action_name) ? 'map' : 'admin' }
  # before_action :allow_embed, only: [:map, :index]
  protect_from_forgery with: :exception

  def map
    @venues = Venue.all
    @events = Event.all
  end

  def manage
    @venues = Venue.limit(10)
  end

  protected

    def allow_embed
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

end
