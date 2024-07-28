class Activity < ApplicationRecord

  # Extensions
  enum category: { status_changed: 1, record_updated: 2, email_sent: 3 }
  store :data, accessors: %i[changes]

  # Associations
  belongs_to :channel, polymorphic: true
  belongs_to :account, polymorphic: true#, optional: true

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :with_associations, -> { includes(:account, :channel) }

  # Callbacks
  # before_create :send_email!, if: :email_sent?

  # Methods
  alias parent channel

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