class CMS::RegistrationsController < CMS::ApplicationController

  prepend_before_action { @model = Registration }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:registration, {}).permit(:name, :email, :comment)
    end

end
