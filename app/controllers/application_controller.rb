class ApplicationController < ActionController::Base

  layout 'cms/application'
  before_action :redirect_login, if: :passwordless_controller?
  skip_before_action :redirect_login, except: %i[sign_out]

  def redirect_login
    redirect_to '/cms' if current_user.present?
  end

  def current_user
    @current_user ||= authenticate_by_session(Manager)
  end

end
