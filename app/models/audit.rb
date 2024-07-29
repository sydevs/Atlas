class Audit < ApplicationRecord

  # Extensions
  enum category: { status_change: 1, record_updated: 2, record_created: 3, record_destroyed: 4, status_verified: 5, email_forwarded: 6, notice_sent: 7 }
  store :data, accessors: %i[changes status]
  # searchable_columns %w[category]

  # Associations
  belongs_to :parent, polymorphic: true
  belongs_to :person, polymorphic: true, optional: true
  belongs_to :conversation, optional: true

  belongs_to :replies_to, class_name: 'Audit', optional: true
  has_one :replied_by, class_name: 'Audit', foreign_key: :replies_to_id

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :with_associations, -> { includes(:parent, :person) }
  scope :messages, -> { where(category: %i[notice_sent email_forwarded]) }
  scope :messages_outstanding, -> { messages.where(replied_by_id: nil) }

  # Callbacks
  before_create :set_uuid
  before_create :update_conversation
  before_create :send_email!, if: :email_forwarded?

  # Methods

  def should_forward_to
    conversation.members - [person]
  end

  def should_reply_to
    "#{uuid}@reply.sydevelopers.com"
  end

  def reply_link
    subject = self.data[:subject]
    subject = 'Re: ' + subject unless subject.start_with?('Re:')
    "mailto:#{should_reply_to}?subject=#{subject}"
  end

  private

    def set_uuid
      self.uuid = SecureRandom.hex(6) + Audit.maximum(:id).to_i.next.to_s
    end

    def update_conversation
      if replies_to&.conversation.present?
        self.conversation = replies_to.conversation
        self.conversation.update!(last_response_at: created_at, last_responder: person)
      elsif email_forwarded? || notice_sent?
        self.conversation = Conversation.create!(last_response_at: created_at, last_responder: person, parent: parent)
      end
    end

    def send_email!
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
      self[:data][:forwarded_to] = should_forward_to.map { |p| { id: p.id, name: p.name, email: p.email } }

      BrevoAPI.send_email(nil, {
        to: self[:data][:forwarded_to].map { |p| p.except(:id) },
        sender: { name: person.name, email: 'admin@wemeditate.com' },
        replyTo: { email: should_reply_to },
        subject: data[:subject],
        htmlContent: markdown.render(data[:body]),
      })
    end

end