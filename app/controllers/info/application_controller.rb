class Info::ApplicationController < ActionController::Base

  include Passwordless::ControllerHelpers
  helper_method :current_user

  def about
  end

  def statistics
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

end
