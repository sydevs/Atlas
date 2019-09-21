class CMS::ManagersController < CMS::ApplicationController

  prepend_before_action { @model = Manager }

  def create
    @record = Manager.find_or_initialize_by(email: parameters[:email])
    authorize @record
    @record.name = parameters[:name] if @record.new_record?
    @context.managers << @record if @context

    if !@record.new_record? || @record.save
      if @record.new_record? || @context.present?
        flash[:success] = "Added #{@model_name.human} successfully"
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
    flash[:success] = translate('messages.successfully_removed', record: Manager, context: @context.class)
    redirect_to [:cms, @context, Manager]
  end

  private

    def parameters
      @parameters ||= params.fetch(:manager, {}).permit(
        :name, :email, :administrator,
        country_ids: [], province_ids: [], local_area_ids: []
      )
    end

end
