class Map::RegistrationsController < ActionController::Base

  include KlaviyoAPI

  def create
    registration = Registration.joins(:event, event: :venue).find_or_initialize_by(registration_params)

    if !registration.new_record?
      render json: { status: 'info', message: I18n.translate('map.registration.feedback.duplicate'), date: registration.created_at.utc }
    elsif registration.save
      # KlaviyoAPI.subscribe(registration)
      KlaviyoAPI.send_registration_event(registration)
      render json: { status: 'success', message: I18n.translate('map.registration.feedback.success') }
    else
      render json: { status: 'error', message: registration.errors.full_messages.first }
    end
  rescue StandardError => error
    render json: { status: 'error', message: translate('map.registration.feedback.error') }
    logger.error error.message
    logger.error error.backtrace.join("\n")
  end

  private

  def registration_params
    params.permit(:event_id, :name, :email, :starting_at)
  end

end
