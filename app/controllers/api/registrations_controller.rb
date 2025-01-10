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
      time = event.recurrence.starts_at.to_fs(:time).split(':')
      args[:starting_at] = DateTime.parse(args[:starting_at]).utc.change(hour: time[0].to_i, min: time[1].to_i)
      args[:user_attributes] = user_params
      args
    end

    def user_params
      params.permit(:name, :email)
    end

end
