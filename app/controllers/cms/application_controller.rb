class CMS::ApplicationController < ActionController::Base

  layout 'cms/application'

  include Passwordless::ControllerHelpers
  include Pundit

  helper_method :current_user, :back_path

  before_action :require_login!
  before_action :verify_manager
  before_action :set_locale!
  before_action :set_model_name!
  before_action :set_context!, only: %i[index new create regions destroy images]
  before_action :set_scope!, except: %i[regions images]
  before_action :set_record!, only: %i[show edit update destroy]
  protect_from_forgery with: :exception

  # TODO: Remove this development code
  after_action :verify_authorized, except: :home
  after_action :verify_policy_scoped, only: :index
  # END TODO

  def home
    raise ActionController::RoutingError.new('Not Found') unless defined?(current_user) && current_user.present?

    redirect_to cms_manager_url(current_user), status: :moved_permanently
  end

  def dashboard
    authorize current_user, :dashboard?
    @resources = current_user.clients
    @resources += current_user.countries
    @resources += current_user.provinces.joins(:country).where(countries: { enable_province_management: true })
    @resources += current_user.areas
    @resources += current_user.events
    @events_for_review = current_user.accessible_events.needs_review
    @events_recently_expired = current_user.accessible_events.expired
    @events_expiring_count = @events_for_review.count + @events_recently_expired.count
    @events_archived_count = current_user.accessible_events.archived.count
  end

  def review
    authorize current_user, :dashboard?
    @events_for_review = current_user.accessible_events.needs_review.order(updated_at: :desc)
    @events_expired = current_user.accessible_events.expired.order(updated_at: :desc)
    @events_archived = current_user.accessible_events.archived.order(updated_at: :desc)
  end

  def index query = {}
    authorize_association! @model
    @query = query
    @scope = @scope.where(query) if query.present?
    @records = policy_scope(@scope).page(params[:page]).per(15).search(params[:q])
    @records = @records.order(updated_at: :desc) if @model.column_names.include?('updated_at')
    @records = @records.with_associations if @records.respond_to?(:with_associations)
    render 'cms/views/index'
  end

  def show
    if @model
      authorize @record
      @context = @record
      registrations = @record.try(:associated_registrations)
    else
      authorize nil, policy_class: WorldwidePolicy
      registrations = Registration
    end

    if registrations
      registrations = registrations.since(6.months.ago).group_by_month.count.map { |k, v| [k.strftime("%b"), v] }.to_h
      recent_month_names = 5.downto(1).collect do |n| 
        Date.parse(Date::MONTHNAMES[n.months.ago.month]).strftime('%b')
      end
      
      @registrations_data = {
        labels: recent_month_names,
        series: [
          {
            name: 'monthly',
            data: recent_month_names.map { |m| registrations[m] || 0 },
          }
        ],
      }
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
      redirect_to back_path, flash: { success: translate('cms.messages.successfully_created', resource: @model.model_name.human.downcase) }
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
      redirect_to back_path, flash: { success: translate('cms.messages.successfully_updated', resource: @model.model_name.human.downcase) }
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
      @areas = @context.areas if @context.respond_to?(:areas)
    else
      @countries = Country.default_scoped
      @areas = Area.international
    end

    render 'cms/views/regions'
  end

  def help
    set_context!
    authorize :dashboard, :view_help?
  end

  def geosearch args = {}
    authorize @record || @model
    args.merge!({
      language: I18n.locale,
      sessiontoken: session.id,
      input: params[:query],
    })

    result = GoogleMapsAPI.predict(args)
    puts "RESULT #{result.inspect}"
    render json: result, status: result ? 200 : 404
  end

  def back_path
    return cms_root_path if @record == current_user
    return url_for([:cms, @record]) if policy(@record).show?
    
    url_for([:cms, @record.parent, @model.model_name.route_key.to_sym])
  end

  protected

    def current_user
      @current_user ||= authenticate_by_session(Manager)
    end

    def require_login!
      return if current_user

      save_passwordless_redirect_location! Manager
      redirect_to managers.sign_in_path, flash: { error: translate('cms.messages.not_logged_in') }
    end

    def verify_manager
      atts = { last_login_at: DateTime.now }
      if params[:verify] && current_user.respond_to?("#{params[:verify]}_verified")
        atts[:"#{params[:verify]}_verified"] = true
        flash.now[:success] = translate("cms.messages.manager.#{params[:verify]}_verified")
      end

      current_user.update!(atts)
    end

    def set_locale!
      I18n.locale = params[:locale]&.to_sym || current_user.language_code&.downcase&.to_sym || :en
    end

    def set_model_name!
      @model_name = @model&.model_name
    end

    def set_context!
      [Registration, Event, Venue, Manager, Area, Province, Country, Client].each do |model|
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
      if @context && @model == Event
        @scope = @context.try(:associated_events) || @context.events
      elsif @context
        @scope = @context.send(@model.table_name)
      elsif @model
        @scope = current_user.try("accessible_#{@model.table_name}") || @model
      end
      
      @query ||= {}
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
