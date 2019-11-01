class API::ApplicationController < ActionController::Base

  before_action :authenticate_access_key!
  before_action :parse_params!

  def index records = nil
    @records = records || scope
    render 'api/views/index'
  end

  def show
    @record = scope.find(params[:id])
    render 'api/views/show'
  end

  def error
    render 'api/views/error', status: request.env['PATH_INFO'][1, 3].to_i
  end

  private

    def scope
      @scope ||= begin
        scope = @model.respond_to?(:published) ? @model.published : @model
        associations = @model.reflect_on_all_associations
        @include.each do |association|
          scope = scope.includes(association) if associations.include?(association)
        end
        scope
      end
    end

    def authenticate_access_key!
      render('api/views/error', status: 400) && return unless params[:key].present?

      AccessKey.find(key: params[:key]).touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render 'api/views/error', status: 401
    end

    def parse_params!
      @include = params[:include]&.split(',')&.map(&:to_sym) || []
    end

end
