class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }
  skip_before_action :verify_authenticity_token, only: %i[upload_image destroy_image] # TODO: Remove this security vulnerability and supply csrf tokens properly

  def create
    super parameters
  end

  def update
    super parameters
  end

  # TODO: Multi-file uploads do not work
  def upload_image
    set_context!
    authorize @context, :update?
    images = @context.images 
    images += params[:files]
    @context.images = images
    @success = @context.save!

    image = @context.images.last
    render json: {
      url: image.url,
      thumbnail_url: image.thumbnail.url,
      delete_url: cms_event_destroy_image_path(@context, index: @context.images.length - 1),
    }.to_json
  end

  def destroy_image
    set_context!
    authorize @context, :update?
    kept_images = @context.images
    index = params[:index].to_i
    if index == 0 && @context.images.size == 1
      @context.remove_images!
    else
      deleted_image = kept_images.delete_at(index) 
      deleted_image.try(:remove!)
      @context.images = kept_images
    end

    @success = @context.save!
    render 'cms/views/reload_images'
  end

  private

    def parameters
      params.fetch(:event, {}).permit(
        :published,
        :name, :description, :room, :category,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        manager: {},
        languages: [],
      )
    end

end
