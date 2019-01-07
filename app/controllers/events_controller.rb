class EventsController < ApplicationController
  before_action :set_venue!, only: [:new, :create]
  before_action :set_event!, only: [:show, :edit, :update, :destroy]
  before_action :set_events!, only: [:index, :map]

  def index
  end

  def map
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
      redirect_to @venue, flash: { info: "Created event" }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update event_params
      redirect_to @venue, flash: { info: "Created event" }
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

    def set_events!
      if params[:venue_id]
        set_venue!
        @events = @venue.events.all
      else
        @events = Event.all
      end
    end

    def event_params
      params.fetch(:event, {}).permit(
        :name, :room, :category, :contact_email, :start_date, :end_date, :start_time, :end_time, :recurrence
      )
    end
end
