class API::EventsController < API::ApplicationController

  prepend_before_action { @model = Event }

  def index
    if params[:latitude].present? && params[:longitude].present?
      @location = [params[:latitude].to_f, params[:longitude].to_f]
      @events = decorate(Event.by_distance(origin: @location).publicly_visible.limit(20))
    else
      @events = decorate(Event.publicly_visible)
    end
  end

end
