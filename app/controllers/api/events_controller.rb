class API::EventsController < API::ApplicationController

  def index
    if params[:latitude].present? && params[:longitude].present?
      @location = [params[:latitude].to_f, params[:longitude].to_f]
      @events = decorate(Event.by_distance(origin: @location).publicly_visible.limit(20))
    else
      @events = decorate(Event.publicly_visible)
    end
  end

  def show
    @event = decorate(Event.find(params[:id]))
  end

end
