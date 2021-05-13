class Mail::EventsController < Mail::ApplicationController

  before_action :fetch_manager

  def welcome
  end

  def summary
    @registrations = @event.registrations.first(10)
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def fetch_manager
      @manager = Event.find(params[:manager_id])
    end

end
