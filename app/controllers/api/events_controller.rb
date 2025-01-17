class API::EventsController < API::ApplicationController

  def index
    events = Event.limit(20).publicly_visible

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
    event = Event.includes(:venue, :area, :pictures).find(params[:id])
    @event = decorate(event)
  end

end
