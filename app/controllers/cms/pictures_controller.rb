class CMS::PicturesController < CMS::ApplicationController

  prepend_before_action { @model = Picture }

  def index
    authorize_association! @model
    @records = policy_scope(@scope)
    render 'cms/views/pictures'
  end

end
