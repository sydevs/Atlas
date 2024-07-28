require 'redcarpet'

class CMS::ActivitiesController < CMS::ApplicationController

  prepend_before_action { @model = Activity }

  def receive
    puts "RECEIVED INBOUND EMAIL"
    pp params

    params[:items].each do |item|
      brevo_id = item["InReplyTo"]
      if brevo_id.present?
        body = [item["ExtractedMarkdownMessage"], item["ExtractedMarkdownSignature"]].compact.join("\n")
        message = Activity.find_by(brevo_id: brevo_id)
        message.channel.reply(body)
      end
    end
  end

end
