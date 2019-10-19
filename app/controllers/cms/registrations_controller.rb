class CMS::RegistrationsController < CMS::ApplicationController

  prepend_before_action { @model = Registration }

  def create
    if super(parameters)
      @record.touch(:latest_registration_at)
      RegistrationMailer.with(registration: @record).confirmation.deliver_now
    end
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:registration, {}).permit(:name, :email, :comment)
    end

end
