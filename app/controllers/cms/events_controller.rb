class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }

  def index
    super online: params[:online] == 'true' || (params[:online] != 'false' && @context.is_a?(LocalArea))
  end

  def new
    super category: params[:category], online: params[:online] == 'true'
  end

  def create
    super parameters
  end

  def update
    @record.touch if super parameters
  end

  def verify
    @record = Event.find(params[:event_id])
    authorize @record, :update?
    @context = @record
    @record.touch
  end

  private

    def parameters
      params.fetch(:event, {}).permit(
        :published,
        :custom_name, :description, :room, :category, :language_code,
        :phone_name, :phone_number,
        :registration_mode, :registration_url, :registration_limit,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        :online, :online_url,
        :manager_id,
        manager_attributes: %i[id name email phone contact_method language_code]
      )
    end

end
