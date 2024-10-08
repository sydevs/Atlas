class API::ApplicationController < ActionController::Base

  before_action :authenticate_client!, except: %i[inbound_email]

  def inbound_email
    params[:items].each do |item|
      to = item["Recipients"].first
      conversation = Conversation.find_by_uuid(to.split('@', 2).first)
      if conversation.present?
        from = (item["ReplyTo"] || item["From"])
        person = Manager.find_by_email(from["Address"]) || User.find_by_email(from["Address"])
        next unless person.present?

        person.update(name: from["Name"]) if from["Name"].present? && person.is_a?(User)

        conversation.messages.create!({
          category: :email_forwarded,
          parent: conversation.parent,
          person: person,
          replies_to: conversation.messages.last,
          created_at: item["SentAtDate"],
          data: {
            spam_score: item["SpamScore"],
            subject: item["Subject"],
            body: item["ExtractedMarkdownMessage"],
            signature: item["ExtractedMarkdownSignature"],
            html: item["RawHtmlBody"],
            uuid: item["Uuid"][0],
            reply_to: person.email,
            message_id: item["MessageId"],
            headers: {
              'In-Reply-To': item["InReplyTo"],
            },
          }
        })
      else
        puts "[Brevo] Rejected inbound email. Target audit not found.\r\n#{item.pretty_inspect}"
      end
    end
  end

  private

    def authenticate_client!
      return if %w[GET HEAD OPTIONS].include?(request.method)
      client = Client.find_by(secret_key: params[:key])
      render('api/views/error', status: 400) && return unless client.present?

      client.touch(:last_accessed_at)
    rescue ActiveRecord::RecordNotFound => _e
      render 'api/views/error', status: 401
    end

end
