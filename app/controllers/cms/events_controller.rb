class CMS::EventsController < CMS::ApplicationController

  prepend_before_action { @model = Event }

  def index
    super type: params[:online] == 'true' ? 'OnlineEvent' : 'OfflineEvent'
  end

  def new
    super category: params[:category], type: params[:online] == 'true' ? 'OnlineEvent' : 'OfflineEvent'
  end

  def create
    super parameters
  end

  def update
    @record.touch if super parameters
  end

  def change
    @record = Event.find(params[:id])
    authorize @record, :update?
    @context = @record

    case params[:effect]
    when 'verify'
      @record.verify!
      message = { success: translate('cms.messages.event.verified') }
    when 'finish'
      unless @record.finished?
        if @record.finish_date.nil? || @record.recurrence_start_date < Time.now
          finish_at = 1.minute.ago
          @record.assign_attributes finish_date: finish_at, recurrence_end_date: finish_at
        else
          @record.assign_attributes published: false
        end

        @record.reset_status
        @record.save!
        message = { success: translate('cms.messages.event.finish') }
      end
    else
      raise ActionController::RoutingError.new('Not Found')
    end
    
    redirect_to [:cms, @record], flash: message
  end

  private

    def parameters
      params.fetch(:event, {}).permit(
        :published, :type,
        :custom_name, :description, :room, :category, :language_code,
        :registration_mode, :registration_url, :registration_notification, :registration_limit,
        :online_url, :expiration_period,
        :venue_id, :manager_id,
        :recurrence_type, :recurrence_start_date, :recurrence_end_date, :recurrence_start_time, :recurrence_end_time,
        registration_question: [],
        contact_info: {},
        venue_attributes: %i[id name place_id latitude longitude street city region_code country_code post_code],
        manager_attributes: %i[id name email phone contact_method language_code]
      )
    end

end
