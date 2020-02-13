class Map::RegistrationsController < ActionController::Base

  def create
    registration = Registration.find_or_initialize_by(registration_params)

    if !registration.new_record?
      render json: { status: 'info', message: I18n.translate('map.registration.feedback.duplicate', date: registration.created_at.to_s(:short)) }
    elsif registration.save
      RegistrationMailer.with(registration: registration).confirmation.deliver_now
      render json: { status: 'success', message: I18n.translate('map.registration.feedback.success') }
    else
      render json: { status: 'error', message: registration.errors.full_messages.first }
    end
  rescue
    render json: { status: 'error', message: translate('map.registration.feedback.error') }
  end

  private

  def registration_params
    params.permit(:event_id, :name, :email, :starting_at)
  end

end
