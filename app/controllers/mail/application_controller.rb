class Mail::ApplicationController < ActionController::Base

  layout 'mail/admin'

  include Passwordless::ControllerHelpers

  helper_method :current_user
  before_action :verify_admin!

  protected

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def verify_admin!
      return if current_user && current_user.administrator?

      raise ActionController::RoutingError.new('Not Found')
    end

end
