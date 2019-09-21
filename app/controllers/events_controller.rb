class EventsController < ApplicationController

  before_action :require_login!
  before_action :set_venue!, only: %i[new create]
  before_action :set_event!, only: %i[show edit update destroy upload_image destroy_image]
  skip_before_action :verify_authenticity_token, only: %i[upload_image]

  def show
    authorize @event
  end

  def new
    @event = @venue.events.new
    authorize @event
  end

  def create
    @event = @venue.events.new event_params
    authorize @event

    if @event.save
      redirect_to @event, flash: { success: 'Created event' }
    else
      render :new
    end
  end

  def edit
    authorize @event
  end

  def update
    authorize @event
    if @event.update event_params
      redirect_to [:edit, @event], flash: { success: 'Saved event' }
    else
      render :edit
    end
  end

  def destroy
    authorize @event
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
      params.fetch(:event, {}).permit(
        :name, :description, :room, :category,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        manager: {},
        languages: [],
      )
    end

end
