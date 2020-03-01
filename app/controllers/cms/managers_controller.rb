class CMS::ManagersController < CMS::ApplicationController

  prepend_before_action { @model = Manager }

  def show
    if policy(@record).dashboard?
      @events_for_review = Event.needs_review
      @events_recently_expired = Event.recently_expired
      @events_expired_count = Event.expired.count
    end

    super
  end

  def create
    @record = Manager.find_or_initialize_by(email: parameters[:email])

    if @context
      authorize @context, :create_manager?
    else
      authorize @record
    end

    new_record = @record.new_record?
    @record.name = parameters[:name] if new_record
    success = false

    if @context.present?
      if @context.managers.where(id: @record.id).exists?
        flash[:error] = "#{@record.name} already manages this #{helpers.translate_model(@context).downcase}"
      elsif !new_record || @record.save
        flash[:success] = "Added #{@model_name.human} successfully"
        @context.managers << @record
        @context.save! validate: false
        ManagerMailer.with(manager: @record, context: @context).welcome.deliver_now if new_record
        success = true
      end
    elsif !new_record
      flash[:notice] = "#{@record.name} <#{@record.email}> already exists"
      success = true
    elsif @record.save
      flash[:success] = "Added #{@model_name.human} successfully"
      ManagerMailer.with(manager: @record, context: @context).welcome.deliver_now if @record.administrator?
      success = true
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
    authorize @record
    raise StandardError, 'Cannot destroy a manager' unless @context

    @context.managers.delete(@record)
    flash[:success] = translate('cms.messages.successfully_removed', resource: Manager, context: @context.class)
    redirect_to [:cms, @context, Manager]
  end

  def activity
    set_context!
    authorize @context, :view_activity?
    @records = policy_scope(@context.actions).page(params[:page]).per(30).search(params[:q])
    @model = Audit
    set_model_name!
    render 'cms/views/activity'
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

    @provinces = manager.accessible_provinces(params[:country_code], area: params[:area])
    render format: :json
  end

  private

    def parameters
      @parameters ||= params.fetch(:manager, {}).permit(
        :name, :email, :administrator,
        country_ids: [], province_ids: [], local_area_ids: []
      )
    end

end
