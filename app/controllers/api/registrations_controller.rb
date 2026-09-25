class API::RegistrationsController < API::ApplicationController

  def create
    # Create registrations
    @event = Event.find(params[:event_id])
    @user = User.find_by_email(params[:email])
    @registration = @event.registrations.find_or_initialize_by(user: @user)
    @registration.assign_attributes(registration_params(@event))
    @registration.save!

    # Setup emails and subscriptions
    @registration.subscribe_to!(:registrations)
    RegistrationMailer.with(registration: @registration).confirmation.deliver_later
    RegistrationMailer.with(registration: @registration).question.deliver_later if @registration.questions['questions'].present?
    BrevoAPI.schedule_reminder_email(@registration)
  end

  protected

    def registration_params(event)
      args = params.permit(:event_id, :questions, :starting_at, :time_zone)
      args[:starting_at] = event.recurrence_on(args[:starting_at])
      args[:user_attributes] = user_params
      args
    end

    def user_params
      params.permit(:name, :email)
    end

end
