class Audit < ApplicationRecord

  # Extensions
  enum category: { status_change: 1, record_updated: 2, record_created: 3, record_destroyed: 4, status_verified: 5, email_sent: 6 }
  store :data, accessors: %i[changes status]
  # searchable_columns %w[category]

  # Associations
  belongs_to :parent, polymorphic: true
  belongs_to :person, polymorphic: true, optional: true

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :with_associations, -> { includes(:parent, :person) }

  # Callbacks
  # before_create :send_email!, if: :email_sent?

  # Methods

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