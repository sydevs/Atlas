class API::RegistrationsController < API::ApplicationController

  def create
    @registration = Registration.create!(registration_params)
  end

  private

    def registration_params
      params.permit(:event_id, :name, :email, :questions, :starting_at, :time_zone, :locale)
    end

end
