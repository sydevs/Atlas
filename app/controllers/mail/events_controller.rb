class Mail::EventsController < Mail::ApplicationController

  before_action :fetch_event

  def status
    @status = params[:status]&.to_sym || @event.status.to_sym || :created
    @status = :created if @status == :verified
    @manager = @event.manager if params[:self]
    @subject = I18n.translate(@status, scope: 'mail.event.status.subject')
  end

  def registrations
    @registrations = @event.registrations.order_with_comments_first
    @subject = I18n.translate('mail.event.registrations.subject')
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def fetch_event
      if params[:event_id]
        @event = Event.find(params[:event_id])
      else
        @event = Event.where.not(status: Event.statuses.values_at(*%w[archived finished])).order('RANDOM()').first
      end
    end

end
