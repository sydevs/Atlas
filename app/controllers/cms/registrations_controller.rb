class CMS::RegistrationsController < CMS::ApplicationController

  prepend_before_action { @model = Registration }

  def create
    return unless super(parameters)

    @record.touch(:latest_registration_at)
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:registration, {}).permit(:name, :email, :comment)
    end

end
