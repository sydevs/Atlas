class Mail::ManagedRecordsController < Mail::ApplicationController

  before_action :fetch_managed_record

  def created
    @subject = I18n.translate(@record.model_name.i18n_key, scope: 'mail.managed_record.created.subject', record: @record.label)
  end

  private

    def fetch_managed_record
      if params[:managed_record_id]
        managed_record = ManagedRecord.joins(:manager).find(params[:managed_record_id])
      elsif params[:type] && params[:type].classify == 'Event'
        @record = Event.joins(:manager).reorder('RANDOM()').first
        @manager = @record.manager
        return
      elsif params[:type] && params[:type].classify == 'Client'
        @record = Client.joins(:manager).reorder('RANDOM()').first
        @manager = @record.manager
        return
      elsif params[:type]
        managed_record = ManagedRecord.joins(:manager).where(record_type: params[:type].classify).reorder('RANDOM()').first
      else
        managed_record = ManagedRecord.joins(:manager).reorder('RANDOM()').first
      end

      @managed_record = managed_record
      @manager = managed_record.manager
      @record = ActiveDecorator::Decorator.instance.decorate(managed_record.record)
    end

end
