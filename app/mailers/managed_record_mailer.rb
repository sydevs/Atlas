class ManagedRecordMailer < ApplicationMailer

  default template_path: 'mail/managed_records'
  layout 'mail/admin'

  def created
    setup
    
    subject = I18n.translate(@record.model_name.i18n_key, scope: 'mail.managed_record.created.subject', record: @record.label)
    puts "[MAIL] Sending new managed record email to #{@manager.name} for #{@record}"
    mail(to: @manager.email, subject: subject)
  end

  private

    def setup
      if params[:event]
        @record = params[:event]
        @manager = @record.manager
      else
        managed_record = params[:managed_record]
        @manager = managed_record.manager
        @record = managed_record.record
      end

      create_session!
    end

end
