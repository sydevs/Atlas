class Mail::EventsController < Mail::ApplicationController

  before_action :fetch_event

  def status
    @subject = I18n.translate(@status, scope: 'mail.event.status.subject')
    @status = params[:status].to_sym || :created
  end

  def reminder
    @registrations = @event.registrations.order('RANDOM()').limit(params[:count].to_i || 10)
    @subject = I18n.translate('mail.event.reminder.subject')
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def fetch_event
      @event = Event.find(params[:event_id])
    end

end
