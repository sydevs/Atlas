class RegistrationsController < ApplicationController

  before_action :set_event!, only: %i[index create]

  def index
    scope = @event.registrations
      
    if params[:q]
      term = "%#{params[:q]}%"
      scope = scope.where('(name LIKE ?) OR (email LIKE ?) OR (comment LIKE ?)', term, term, term)
    end

    if params[:format] != :csv
      scope = scope.page(params[:page]).per(30)
    end

    @registrations = scope

    respond_to do |format|
      format.html
      format.js
      format.csv { send_data @registrations.to_csv, filename: "registrations-#{Date.today}.csv" }
    end
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
