class Audit < ApplicationRecord

  MESSAGE_CATEGORIES = %i[notice_sent email_forwarded]

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
  scope :messages, -> { where(category: MESSAGE_CATEGORIES) }
  scope :messages_outstanding, -> { messages.where(replied_by_id: nil) }

  # Validations
  validates_presence_of :conversation, if: :message_test?

  # Callbacks
  before_create :update_conversation, if: :message?
  before_create :send_email!, if: :email_forwarded?

  # Methods
  
  def message_test?
    puts "MESSAGE TEST? #{category.to_sym.inspect} in? #{MESSAGE_CATEGORIES.inspect} -> #{MESSAGE_CATEGORIES.include?(category.to_sym)}"
    MESSAGE_CATEGORIES.include?(category.to_sym)
  end
  
  def message?
    puts "MESSAGE? #{category.to_sym.inspect} in? #{MESSAGE_CATEGORIES.inspect} -> #{MESSAGE_CATEGORIES.include?(category.to_sym)}"
    MESSAGE_CATEGORIES.include?(category.to_sym)
  end

  def reply_link
    return nil unless conversation.present?

    subject = self.data[:subject]
    subject = 'Re: ' + subject unless subject.start_with?('Re:')
    "mailto:#{conversation.reply_to}?subject=#{subject}"
  end

  private

    def update_conversation
      return if conversation.present?

      puts "UPDATE CONVERSATION"
      if replies_to&.conversation.present?
        puts "SET CONVERSATION"
        self.conversation = replies_to.conversation
      else
        puts "CREATE CONVERSATION"
        self.conversation = Conversation.new(last_response_at: created_at, last_responder: person, parent: parent)
      end
      puts "CONVERSATION DONE"
    end

    def send_email!
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
      forward_to = conversation.members - [person]
      self[:data][:forwarded_to] = forward_to.map { |p| { id: p.id, name: p.name, email: p.email } }

      BrevoAPI.send_email(nil, {
        to: self[:data][:forwarded_to].map { |p| p.except(:id) },
        sender: { name: person.name, email: 'admin@wemeditate.com' },
        replyTo: { email: conversation.reply_to },
        subject: data[:subject],
        htmlContent: markdown.render(data[:body]),
      })
    end

end