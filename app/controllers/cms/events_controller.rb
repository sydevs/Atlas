class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }

  def index
    online = params[:online] == 'true' || (params[:online] != 'false' && @context.is_a?(LocalArea))
    super type: online ? 'OnlineEvent' : 'OfflineEvent'
  end

  def new
    super category: params[:category], type: params[:online] ? 'OnlineEvent' : 'OfflineEvent'
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
        :published, :type,
        :custom_name, :description, :room, :category, :language_code,
        :phone_name, :phone_number,
        :registration_mode, :registration_url, :registration_limit,
        :recurrence, :start_date, :end_date, :start_time, :end_time,
        :online_url,
        :venue_id, :manager_id,
        venue_attributes: %i[id name address place_id latitude longitude],
        manager_attributes: %i[id name email phone contact_method language_code]
      )
    end

end
