class CMS::AccessKeysController < CMS::ApplicationController

  prepend_before_action { @model = AccessKey }

  def new
    super key: SecureRandom.uuid
  end

  def create
    @record = @scope.new(parameters)
    authorize @record

    if @record.save
      redirect_to [:cms, @model], flash: { success: translate('cms.messages.successfully_created', resource: @model) }
    else
      render 'cms/views/new'
    end
  end

  def update
    authorize @record
    if @record.update(parameters)
      redirect_to [:cms, @model], flash: { success: translate('cms.messages.successfully_updated', resource: @model) }
    else
      render 'cms/views/edit'
    end
  end

  private

    def parameters
      params.fetch(:access_key, {}).permit(:label, :key, :suspended)
    end

end
