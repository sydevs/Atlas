class API::ApplicationController < ActionController::Base

  before_action :authenticate_client!

  def error
    render_error(request.path.split('/').last)
  end

  protected

    def render_error status
      render json: { status: status.to_i }, status: status.to_i
    end

    def authenticate_client!
      return if %w[GET HEAD OPTIONS].include?(request.method)
      client = Client.find_by(secret_key: params[:key])
      render_error(400) && return unless client.present?

      client.touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render_error(401)
    end

end
