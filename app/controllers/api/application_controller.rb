class API::ApplicationController < ActionController::Base

  before_action :authenticate_client!, except: %i[inbound_email]
  before_action :set_locale!

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

  def geojson
    @venues = Venue.publicly_visible
  end

  protected

    def decorate object
      return nil if object.nil?

      klass = object.is_a?(Enumerable) ? object.first.class : object.class
      klass = Event if klass.base_class == Event

      if object.is_a?(Enumerable)
        object.map { |r| r.extend("#{klass}Decorator".constantize) }
      else
        object.extend("#{klass}Decorator".constantize)
      end
    end

  private

    def authenticate_client!
      # TODO: Remove this check once we're ready to launch the REST api
      return if %w[GET HEAD OPTIONS].include?(request.method)
      
      render json: { error: 'Missing api key' }, status: 400 && return unless params[:key].present?
      client = Client.find_by(secret_key: params[:key])
      render json: { error: 'Invalid api key' }, status: 401 && return unless client.present?

      client.touch(:last_accessed_at)
    end

    def set_locale!
      I18n.locale = params[:locale]&.to_sym || :en
    end

end
