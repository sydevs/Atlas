class API::ApplicationController < ActionController::Base

  before_action :authenticate_access_key!

  def index records = nil
    @verbose = params[:verbose] == 'true' || !params.key?(:verbose)
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
        model_key = @model.model_name.route_key

        if params[:country_id]
          scope = Country.find(params[:country_id]).send(model_key)
        elsif params[:province_id]
          scope = Province.find(params[:province_id]).send(model_key)
        elsif params[:local_area_id]
          scope = LocalArea.find(params[:local_area_id]).send(model_key)
        elsif params[:venue_id]
          scope = Venue.find(params[:venue_id]).send(model_key)
        else
          scope = @model
        end

        if @verbose
          associations = @model.reflect_on_all_associations.map(&:name).map(&:to_sym)
          scope.includes(*associations) if associations.present?
        end

        scope.respond_to?(:published) ? scope.published : scope
      end
    end

    def authenticate_access_key!
      return if %w[GET HEAD OPTIONS].include?(request.method)
      render('api/views/error', status: 400) && return unless params[:key].present?

      AccessKey.find(key: params[:key]).touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render 'api/views/error', status: 401
    end

end
