class CMS::ManagersController < CMS::ApplicationController

  prepend_before_action { @model = Manager }

  def index
    if @context
      authorize_association! Manager
      @scope = @context.managed_records || Manager
      @records = policy_scope(@scope).page(params[:page]).per(10).search(params[:q])
      @records = @records.joins(:manager).order('managers.updated_at': :desc)
      render 'cms/views/index'
    elsif request.format.json?
      authorize Manager, :index?
      @records = policy_scope(Manager).limit(3).search(params[:q])
      @email_match = params[:q] if params[:q] =~ URI::MailTo::EMAIL_REGEXP
      @phone_match = Phonelib.parse(params[:q]).international if Phonelib.valid?(params[:q])
      @exact_match = @records.count == 1 && (@records.first.email == @email_match || @records.first.phone == @phone_match)
    else
      super
    end
  end

  def create
    manager_params = parameters
    @record = Manager.find_or_initialize_by(email: manager_params[:email].downcase)

    if @context
      authorize @context, :create_manager?
    else
      authorize @record
    end

    new_record = @record.new_record?
    @record.name = manager_params[:name] if new_record
    @record.administrator = manager_params[:administrator] if manager_params.key?(:administrator)
    success = false

    ActiveRecord::Base.transaction do
      if @context.present?
        if @context.managers.where(id: @record.id).exists?
          flash[:error] = translate('cms.messages.manager.already_added', manager: @record.name, resource: @context.model_name.singular)
        elsif !new_record || @record.save
          flash[:success] = translate('cms.messages.manager.success')
          @context.managed_records << ManagedRecord.new(manager: @record, record: @context, assigned_by_id: current_user.id)
          @context.save! validate: false
          success = true
        end
      elsif !new_record
        flash[:notice] = translate('cms.messages.manager.already_exists', name: @record.name, email: @record.email)
        success = true
      elsif @record.save
        flash[:success] = translate('cms.messages.manager.success')
        ManagerMailer.with(manager: @record, context: @context).welcome.deliver_later if @record.administrator?
        success = true
      end
    rescue Net::SMTPServerBusy
      flash[:error] = translate('cms.messages.temporary_mail_error')
      raise ActiveRecord::Rollback
    end

    if success
      redirect_to [:cms, @context, Manager]
    else
      render 'cms/views/new'
    end
  end

  def update
    super parameters
  end

  def destroy
    if @context && !@context.is_a?(Manager)
      @managed_record = @context.managed_records.find_by(manager_id: @record.id) if @context
      authorize @managed_record

      @context.managers.delete(@record)
      flash[:success] = translate('cms.messages.successfully_removed', resource: Manager, context: @context.class)
      redirect_to [:cms, @context, Manager]
    else
      super
    end
  end

  def activity
    set_context!
    authorize @context, :view_activity?
    @records = policy_scope(@context.actions).page(params[:page]).per(30).search(params[:q])
    @model = Audit
    set_model_name!
    render 'cms/views/activity'
  end

  def search
    @records = @scope.limit(3).search(params[:q])
    authorize Application, :index?
  end

  def countries
    manager = @scope&.find(params[:manager_id])
    authorize manager

    @countries = manager.accessible_countries(area: params[:area])
    render format: :json
  end

  def provinces
    manager = @scope&.find(params[:manager_id])
    authorize manager
    country_code = params[:country_code]

    if Country.where(country_code: country_code, enable_province_management: false).exists?
      render json: {
        success: true,
        results: ISO3166::Country[country_code].subdivisions.map { |k, v|
          name = v['name'] || v['translations'][I18n.locale.to_s]
          return unless name.present?

          name = name.split(' [')[0]
          { name: name, value: k }
        }.compact
      }
    else
      @provinces = manager.accessible_provinces(country_code, area: params[:area])
      render format: :json
    end
  end

  def clients
    manager = @scope&.find(params[:manager_id])
    authorize manager

    @clients = manager.clients
    render format: :json
  end

  def resend_verification
    manager = @scope&.find(params[:manager_id])
    authorize manager
    ManagerMailer.with(manager: manager).verify.deliver_later
    manager.touch(:email_verification_sent_at)
    flash[:success] = translate('cms.messages.manager.email_verification_resent', name: manager.name)
    redirect_back(fallback_location: cms_manager_path(manager))
  end

  private

    def parameters
      if current_user.administrator?
        params.fetch(:manager, {}).permit(
          :name, :administrator, :language_code,
          :email, :phone, :contact_method,
          notifications: [],
          country_ids: [], province_ids: [], local_area_ids: []
        )
      else
        params.fetch(:manager, {}).permit(
          :name, :language_code,
          :email, :phone, :contact_method,
          notifications: [],
          country_ids: [], province_ids: [], local_area_ids: []
        )
      end
    end

end
