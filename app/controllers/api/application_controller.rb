class API::ApplicationController < ActionController::Base

  before_action :authenticate_access_key!

  private

    def authenticate_access_key!
      return if %w[GET HEAD OPTIONS].include?(request.method)
      render('api/views/error', status: 400) && return unless params[:key].present?

      AccessKey.find(key: params[:key]).touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render 'api/views/error', status: 401
    end

end
