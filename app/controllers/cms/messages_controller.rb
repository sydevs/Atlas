require 'redcarpet'

class CMS::MessagesController < CMS::ApplicationController

  prepend_before_action { @model = Message }

  def receive
    puts "RECEIVED INBOUND EMAIL"
    pp params

    params[:items].each do |item|
      brevo_id = item["InReplyTo"]
      if brevo_id.present?
        body = [item["ExtractedMarkdownMessage"], item["ExtractedMarkdownSignature"]].compact.join("\n")
        message = Message.find_by(brevo_id: brevo_id)
        message.reply(body)
      end
    end
  end

end
