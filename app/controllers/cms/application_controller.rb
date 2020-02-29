class CMS::ApplicationController < ActionController::Base

  layout 'cms/application'

  include Passwordless::ControllerHelpers
  include Pundit

  helper_method :current_user

  before_action :require_login!
  before_action :set_model_name!
  before_action :set_context!, only: %i[index new create regions destroy images]
  before_action :set_scope!, except: %i[regions images]
  before_action :set_record!, only: %i[show edit update destroy]
  protect_from_forgery with: :exception

  # TODO: Remove this development code
  after_action :verify_authorized, except: :home
  after_action :verify_policy_scoped, only: :index
  # END TODO

  def index
    authorize_association! @model
    @records = policy_scope(@scope).page(params[:page]).per(10).search(params[:q])
    @records = @records.order(updated_at: :desc) if @records.respond_to?(:updated_at)
    @records = @records.with_associations if @records.respond_to?(:with_associations)
    render 'cms/views/index'
  end

  def show
    if @model
      authorize @record
      @context = @record
    else
      authorize nil, policy_class: WorldwidePolicy
    end

    render 'cms/views/show'
  end

  def new attributes = {}
    @record = @scope.new(**attributes)
    authorize @record
    render 'cms/views/new'
  end

  def create attributes
    @record = @scope.new(attributes)
    authorize @record

    if @record.save
      redirect_to [:cms, @record], flash: { success: translate('cms.messages.successfully_created', resource: @model.model_name.human.downcase) }
      true
    else
      render 'cms/views/new'
      false
    end
  end

  def edit
    authorize @record
    render 'cms/views/edit'
  end

  def update attributes
    authorize @record
    if @record.update(attributes)
      redirect_to [:cms, @record], flash: { success: translate('cms.messages.successfully_updated', resource: @model.model_name.human.downcase) }
      true
    else
      render 'cms/views/edit'
      false
    end
  end

  def destroy
    authorize @record
    @record.destroy

    flash[:success] = translate('cms.messages.successfully_deleted', resource: @model.model_name.human.titleize)
    redirect_to [:cms, @record.parent, @model]
  end

  def regions
    authorize_association! :regions

    if @context
      @countries = @context.countries if @context.respond_to?(:countries)
      @provinces = @context.provinces if @context.respond_to?(:provinces)
      @local_areas = @context.local_areas if @context.respond_to?(:local_areas)
    else
      @countries = Country.all
      @local_areas = LocalArea.international.all
    end

    render 'cms/views/regions'
  end

  private

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def require_login!
      return if current_user

      save_passwordless_redirect_location! Manager
      redirect_to managers.sign_in_path, flash: { error: translate('cms.messages.not_logged_in') }
    end

    def set_model_name!
      @model_name = @model&.model_name
    end

    def set_context!
      [Registration, Event, Venue, Manager, LocalArea, Province, Country].each do |model|
        keys = model.model_name
        param_key = "#{keys.param_key}_id"
        next unless params[param_key]

        context_record = model.find(params[param_key])
        @context_key = keys.route_key
        @context = context_record
        break
      end

      puts "SET CONTEXT #{@context.inspect}"
    end

    def set_scope!
      @scope = @context ? @context.send(@model.table_name) : @model
      puts "SET SCOPE #{@scope.inspect}"
    end

    def set_record!
      @record = @scope&.find(params[:id])
      @context ||= @record
      puts "SET RECORD #{@record.inspect}"
    end

    def authorize_association! key
      skip_authorization
      allow = @context ? policy(@context) : policy(:worldwide)
      key = key.table_name.to_sym if key.is_a?(ActiveRecord.class)
      return if allow.index_association?(key)

      raise Pundit::NotAuthorizedError, "not allowed to index? #{@model} for #{@context || 'Worldwide'}"
    end

end
