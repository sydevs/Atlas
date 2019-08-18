class EventsController < ApplicationController

  before_action :set_venue!, only: %i[new create]
  before_action :set_event!, only: %i[show edit update destroy upload_image destroy_image]
  skip_before_action :verify_authenticity_token, only: %i[upload_image]

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

  def upload_image
    images = @event.images 
    images += params[:files]
    @event.images = images
    @success = @event.save

    image = @event.images.last
    render json: {
      url: image.url,
      thumbnail_url: image.thumbnail.url,
      delete_url: event_destroy_image_path(@event, index: @event.images.length - 1),
    }.to_json
  end

  def destroy_image
    kept_images = @event.images
    if index == 0 && @event.images.size == 1
      @event.remove_images!
    else
      deleted_image = kept_images.delete_at(params[:index].to_i) 
      deleted_image.try(:remove!)
      @event.images = kept_images
    end

    @success = @event.save
    render 'reload_images'
  end

  private

    def set_venue!
      @venue = Venue.find(params[:venue_id])
    end

    def set_event!
      @event = Event.find(params[:id] || params[:event_id])
      @venue = @event.venue
    end

    def event_params
      result = params.fetch(:event, {}).permit(
        :name, :description, :room, :category,
        :contact_name, :contact_email,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        languages: [],
      )
    end

end
