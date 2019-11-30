class CMS::ManagersController < CMS::ApplicationController

  prepend_before_action { @model = Manager }

  def create
    @record = Manager.find_or_initialize_by(email: parameters[:email])

    if @context
      authorize @context, :create_manager?
    else
      authorize @record
    end

    new_record = @record.new_record?
    @record.name = parameters[:name] if new_record
    @context.managers << @record if @context

    if !new_record || @record.save
      if new_record || @context.present?
        flash[:success] = "Added #{@model_name.human} successfully"
        ManagerMailer.with(manager: @record, context: @context).welcome.deliver_now if @context.present? || @record.administrator?
      else
        flash[:notice] = "#{@record.name} <#{@record.email}> already exists"
      end

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

  private

    def parameters
      @parameters ||= params.fetch(:manager, {}).permit(
        :name, :email, :administrator,
        country_ids: [], province_ids: [], local_area_ids: []
      )
    end

end
