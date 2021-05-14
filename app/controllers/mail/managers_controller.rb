class Mail::ManagersController < Mail::ApplicationController

  before_action :fetch_manager

  def welcome
    @subject = I18n.translate('mail.manager.welcome.title')
  end

  def summary
    @registrations = @event.registrations.first(10)
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def fetch_manager
      if params[:manager_id]
        @manager = Manager.find(params[:manager_id])
      else
        @manager = Manager.reorder('RANDOM()').first
      end

      @context = @manager.parent
    end

end
