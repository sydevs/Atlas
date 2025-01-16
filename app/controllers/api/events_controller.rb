class API::EventsController < API::ApplicationController

  def index
    events = Event.publicly_visible.limit(20)

    if params[:online] == 'true'
      events = events.online
    end

    if params[:latitude].present? && params[:longitude].present?
      @location = [params[:latitude].to_f, params[:longitude].to_f]
      events = events.by_distance(origin: @location)
    end

    @events = decorate(events)
  end

  def show
    event = Event.find(params[:id]).includes(:venue, :area, :pictures)
    @event = decorate(event)
  end

end
