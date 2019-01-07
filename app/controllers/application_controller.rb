class ApplicationController < ActionController::Base
  layout Proc.new{ ['index', 'map'].include?(action_name) ? 'map' : 'admin' }
  protect_from_forgery with: :exception

  def index
    @events = Event.all
  end

  def manage
    @venues = Venue.limit(10)
  end
end
