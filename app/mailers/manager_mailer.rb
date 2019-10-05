
class ManagerMailer < ApplicationMailer
 
  def welcome
    @manager = params[:manager]
    @event = params[:event]
    mail(to: @manager.email, subject: "Welcome to SYDB since - #{@event.label} Program")
  end

  def registrations
    @manager = params[:manager]
    @event = params[:event]
    @since = params[:since]
    @registrations = params[:registrations] || @event&.registrations
    @registrations = @registrations.where('created_at > ?', @since) if @since
    mail(to: @manager.email, subject: "Public Program Registrations since #{@since.to_s(:short)}")
  end

  def verification
    @manager = params[:manager]
    @event = params[:event]
    mail(to: @manager.email, subject: "Public Program Verification - #{@event.label}")
  end
  
end
