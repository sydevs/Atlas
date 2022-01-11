class Mail::ManagersController < Mail::ApplicationController

  before_action :fetch_manager, except: %i[verify]

  def login
    @magic_link = cms_root_url
    render 'mail/application/magic_link'
  end

  def welcome
    @subject = I18n.translate('mail.manager.welcome.title')
  end

  def verify
    fetch_manager(Manager.joins(:events))
    @context = @manager.events.first
    @magic_link = cms_root_url
    @subject = I18n.translate('mail.manager.verify.subject')
  end

  private

    def fetch_manager scope = Manager
      if params[:manager_id]
        @manager = scope.find(params[:manager_id])
      else
        @manager = scope.reorder('RANDOM()').first
      end

      @context = @manager.parent
    end

end
