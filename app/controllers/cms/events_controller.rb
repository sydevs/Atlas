class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }
  after_action :set_manager, only: %i[create update]

  def create
    super parameters
  end

  def update
    super parameters
  end

  def confirm
    @record = Event.find(params[:event_id])
    authorize @record, :update?
    @record.touch
    redirect_to [:cms, @record], flash: { success: translate('cms.messages.successfully_confirmed', resource: @model.model_name.human.downcase) }
  end

  private

    def parameters
      result = params.fetch(:event, {}).permit(
        :published,
        :name, :description, :room, :category, :language, :disable_notifications,
        :registration_mode, :registration_url,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        manager_attributes: {}
      )

      @existing_manager = Manager.find_by(email: result[:manager_attributes][:email])
      @existing_manager ? result.except(:manager_attributes) : result
    end

    def set_manager
      return unless @existing_manager

      old_manager_id = @record.manager.id
      @record.manager = @existing_manager
      @record.save!

      Manager.set_counter('Event', :decrement, old_manager_id)
      Manager.set_counter('Event', :increment, @existing_manager.id)
    end

end
