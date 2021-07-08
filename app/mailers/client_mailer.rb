class EventMailer < ApplicationMailer

  default template_path: 'mail/events'
  layout 'mail/admin'

  def summary
    # stub
  end

  private

    def setup
      @client = params[:client] || params[:record]
      @manager = params[:manager] || @client.manager
    end

end
