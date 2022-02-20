class EventMailer < ApplicationMailer

  default template_path: 'mail/events'
  layout 'mail/admin'

  def summary
    setup
    return unless @manager.notifications.client_summary?

    # stub
  end

  private

    def setup
      @client = params[:client] || params[:record]
      @manager = params[:manager] || @client.manager
    end

end
