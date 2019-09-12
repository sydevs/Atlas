class RegistrationsController < ApplicationController

  before_action :require_login!, except: %i[create]
  before_action :set_event!, only: %i[index create]

  def index
    authorize @event, :registrations?
    @registrations = @event.registrations
  end

  def create
    logger.debug params
    @registration = @event.registrations.new registration_params

    if @registration.save
      render json: {
        status: 'success',
        message: "You have been registered.\r\nYou should receive a confirmation email shortly.",
      }
    else
      render json: {
        status: 'error',
        message: @registration.errors.full_messages.join("\r\n"),
      }
    end
  end

  private

    def set_event!
      @event = Event.find(params[:event_id])
    end

    def registration_params
      params.fetch(:registration, {}).permit(:name, :email, :comment)
    end

end
