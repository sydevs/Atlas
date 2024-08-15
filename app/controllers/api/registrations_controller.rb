class API::RegistrationsController < API::ApplicationController

  def remind
    registration = Registration.find_by_uuid(params[:registration_id])
    registration.set_reminder!
    
    tag = ActionController::Base.helpers.tag
    @title = translate('api.registration.remind.title')
    @description = translate('api.registration.remind.description', event: tag.b(registration.event.label), date: tag.i(registration.next_reminder_at.to_date.to_fs(:long))).html_safe
    render 'api/application/response'
  end

  def subscribe
    registration = Registration.find_by_uuid(params[:registration_id])
    MailingListAPI.subscribe!(registration)

    @title = translate('api.registration.subscribe.title')
    @description = translate('api.registration.subscribe.description')
    render 'api/application/response'
  end

end
