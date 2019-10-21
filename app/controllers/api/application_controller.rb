class API::ApplicationController < ActionController::Base

  before_action :parse_params!

  def index records = nil
    @records = records || scope
    render 'api/views/index'
  end

  def show
    @record = scope.find(params[:id])
    render 'api/views/show'
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

    def parse_params!
      @include = params[:include]&.split(',')&.map(&:to_sym) || []
    end

end
