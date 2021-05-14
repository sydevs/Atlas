class ApplicationMailer < ActionMailer::Base

  helper Mail::ApplicationHelper
  helper LocalizationHelper
  layout 'mail/admin'
  default template_path: 'mail'
  default from: 'Sahaj Atlas <contact@sydevelopers.com>'

  def summary
    # TODO: Implement
  end

  protected

    def create_session!
      session = Passwordless::Session.new({
        authenticatable: @manager,
        user_agent: 'Command Line',
        remote_addr: 'unknown',
      })

      session.save!
      @magic_link ||= send(Passwordless.mounted_as).token_sign_in_url(session.token)
      @template_link ||= "#{@magic_link}?destination_path="
    end

end
