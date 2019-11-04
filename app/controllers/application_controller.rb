class ApplicationController < ActionController::Base

  layout 'cms/application'

  def current_user
    @current_user ||= authenticate_by_session(Manager)
  end

end
