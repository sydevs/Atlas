class CMS::PicturesController < CMS::ApplicationController

  prepend_before_action { @model = Picture }
  skip_before_action :verify_authenticity_token, only: %i[create]

  def index
    authorize_association! @model
    @records = policy_scope(@scope)
    render 'cms/views/pictures'
  end

  def create
    picture = @scope.new
    authorize picture

    picture.file = params[:files].first
    picture.save!

    render json: {
      url: picture.file.url,
      thumbnail_url: picture.file.thumbnail.url,
      delete_url: url_for([:cms, @context, picture]),
    }.to_json
  end

  def destroy
    authorize @record
    @record.destroy
    render 'cms/views/pictures'
  end

end
