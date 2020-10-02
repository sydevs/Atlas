class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }

  def create
    super parameters
  end

  def update
    @record.touch if super parameters
  end

  def confirm
    @record = Event.find(params[:event_id])
    authorize @record, :update?
    @record.touch
    redirect_to [:cms, @record], flash: { success: translate('cms.messages.successfully_confirmed', resource: @model.model_name.human.downcase) }
  end

  private

    def parameters
      params.fetch(:event, {}).permit(
        :published,
        :name, :description, :room, :category, :language_code, :disable_notifications,
        :registration_mode, :registration_url,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        :online, :online_url,
        manager_attributes: %i[email name]
      )
    end

end
