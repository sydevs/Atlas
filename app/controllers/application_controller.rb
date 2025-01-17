class ApplicationController < ActionController::Base

  layout 'cms/application'
  before_action :set_current_user, except: %i[embed]
  before_action :redirect_login, if: :passwordless_controller?
  skip_before_action :redirect_login, except: %i[sign_out]
  
  def redirect_login
    return unless current_user.present?

    redirect_to params[:url] || '/cms'
  end

  def passwordless_controller?
    false
  end

  private

    def set_current_user
      Current.user ||= authenticate_by_session(Manager).extend(ManagerDecorator)
    end

end
