class Message < ActsAsMessageable::Message

  # Associations
  belongs_to :channel, polymorphic: true

  # Callbacks
  # before_create :send_email!, if: :sent_messageable_id?

  # Methods

  def name
    sent_messageable&.name || "System"
  end

  def initials
    @initials ||= sent_messageable.name.split.map(&:first).join('').upcase
  end

  def background_color
    @background_color ||= "#" + "%06x" % (Random.new(sent_messageable_id).rand * 0xffffff)
  end

  def text_color
    @text_color ||= begin
      rgb = background_color.match(/^#(..)(..)(..)$/).captures.map(&:hex)
      (rgb[0]*0.299 + rgb[1]*0.587 + rgb[2]*0.114) > 186 ? "#000000" : "#ffffff"
    end
  end

  private

    def send_email!
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

      self.brevo_id = BrevoAPI.send_email(nil, {
        to: { name: received_messageable.name, email: received_messageable.email },
        sender: { name: sent_messageable.name, email: "auto@reply.sydevelopers.com" },
        replyTo: { email: "auto@reply.sydevelopers.com" },
        subject: topic,
        htmlContent: markdown.render(body),
      })
    end

end