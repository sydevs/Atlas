class EventsController < ApplicationController

  before_action :set_venue!, only: %i[new create]
  before_action :set_event!, only: %i[show edit update destroy]

  def index
    if params[:venue_id]
      set_venue!
      @events = @venue.events.all
    else
      @events = Event.all
    end
  end

  def show
  end

  def manage
    if params[:venue_id]
      set_venue!
      @events = @venue.events.all
    else
      @events = Event.all
    end
  end

  def new
    @event = @venue.events.new
  end

  def create
    @event = @venue.events.new event_params

    if @event.save
      redirect_to @event, flash: { success: 'Created event' }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update event_params
      redirect_to [:edit, @event], flash: { success: 'Saved event' }
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
  end

  private

    def set_venue!
      @venue = Venue.find(params[:venue_id])
    end

    def set_event!
      @event = Event.find(params[:id])
      @venue = @event.venue
    end

    def event_params
      params.fetch(:event, {}).permit(
        :name, :description, :room, :category,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        manager: {},
        languages: [],
      )
    end

end
