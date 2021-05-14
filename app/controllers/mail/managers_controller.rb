class Mail::ManagersController < Mail::ApplicationController

  before_action :fetch_manager

  def login
    @magic_link = cms_root_url
    render 'mail/magic_link'
  end

  def welcome
    @subject = I18n.translate('mail.manager.welcome.title')
  end

  private

    def fetch_manager
      if params[:manager_id]
        @manager = Manager.find(params[:manager_id])
      else
        @manager = Manager.reorder('RANDOM()').first
      end

      @context = @manager.parent
    end

end
