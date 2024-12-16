class API::RegistrationsController < API::ApplicationController

  def create
    @event = Event.find(params[:event_id])
    @registration = @event.registrations.create!(registration_params)
  end

  private

    def registration_params
      params.permit(:event_id, :name, :email, :questions, :starting_at, :time_zone, :locale)
    end

end
