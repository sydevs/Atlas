class CMS::ApplicationController < ActionController::Base

  layout 'admin'

  include Passwordless::ControllerHelpers
  include Pundit
  
  helper_method :current_user

  before_action :require_login!
  before_action :set_model_name!
  before_action :set_context!, only: %i[index new create regions]
  before_action :set_scope!, except: %i[regions]
  before_action :set_record!, only: %i[show edit update destroy]
  protect_from_forgery with: :exception
  
  # TODO: Remove this development code
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index
  # END TODO

  def index
    permission = "index_#{@model.table_name}?".to_sym

    if @context
      authorize @context, permission
      scope = @context.send(@model.table_name)
    else
      authorize nil, permission, policy_class: WorldwidePolicy
      scope = @model
    end

    @records = policy_scope(@scope).page(params[:page]).per(10).search(params[:q])
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
      redirect_to [:cms, @record], flash: { success: "Created #{@model_name.human} successfully" }
    else
      render 'cms/views/new'
    end
  end

  def edit
    authorize @record
    render 'cms/views/edit'
  end

  def update attributes
    authorize @record
    if @record.update(attributes)
      redirect_to [:cms, @record], flash: { success: "Saved #{@model_name.human} successfully" }
    else
      render 'cms/views/edit'
    end
  end

  def destroy
    authorize @record
    flash[:success] = translate('messages.successfully_deleted_region', region: @model_name.human)
    redirect_to @model
    @record.destroy
  end

  def regions
    authorize @context, :index_regions?, policy_class: (WorldwidePolicy if @context.nil?)

    if @context
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
      redirect_to managers.sign_in_path, flash: { error: 'You are not logged in!' }
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
        
        next if @context.present?
        @context_key = keys.route_key
        @context = context_record
      end
    end

    def set_scope!
      @scope = @context ? @context.send(@model.table_name) : @model
      puts "SET SCOPE #{@scope}"
    end

    def set_record!
      @record = @scope&.find(params[:id])
      puts "SET RECORD #{@record}"
    end

end
