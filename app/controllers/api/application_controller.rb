class API::ApplicationController < ActionController::Base

  before_action :authenticate_access_key!

  private

    def authenticate_access_key!
      return if %w[GET HEAD OPTIONS].include?(request.method)
      client = Client.find_by(secret_key: params[:key])
      render('api/views/error', status: 400) && return unless client.present?

      client.touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render 'api/views/error', status: 401
    end

end
