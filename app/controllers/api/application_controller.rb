class API::ApplicationController < ActionController::Base

  before_action :authenticate_client!

  private

    def authenticate_client!
      return if %w[GET HEAD OPTIONS].include?(request.method)
      client = Client.find_by(secret_key: params[:key])
      render('api/views/error', status: 400) && return unless client.present?

      client.touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render 'api/views/error', status: 401
    end

end
