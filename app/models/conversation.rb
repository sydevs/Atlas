class Conversation < ApplicationRecord

  # Associations
  belongs_to :parent, polymorphic: true
  belongs_to :last_responder, polymorphic: true, optional: true
  has_many :messages, class_name: 'Audit', after_add: :added_message
  has_many :users, through: :messages, source: :person, source_type: 'User'
  has_many :managers, through: :messages, source: :person, source_type: 'Manager'

  # Scopes
  default_scope { order(last_response_at: :asc) }
  # scope :with_associations, -> { includes(:messages, :last_responder) }
  scope :active, -> { joins(:messages).group('conversations.id').having("count(CASE WHEN audits.category in (#{Audit::MESSAGE_CATEGORIES.excluding(:notice_sent).map{ |k| Audit.categories[k] }.join(', ')}) THEN 1 END) > 0") }
  scope :open, -> { active.where(marked_complete_at: nil).or(where('marked_complete_at < last_response_at')) }
  scope :awaiting_response, -> { open.where(last_responder_type: 'User') }

  # Callbacks
  before_create :generate_uuid

  # Methods
  delegate :managed_by?, to: :parent

  def open?
    marked_complete_at.nil? || marked_complete_at < last_response_at
  end
  
  def awaiting_response?
    open? && last_responder_type == 'User'
  end
  
  def members
    (parent.conversation_members + users + managers).to_set
  end

  def reply_to
    "#{uuid}@reply.sydevelopers.com"
  end

  def generate_uuid
    max_id = Conversation.maximum(:id)
    next_id = max_id.present? ? max_id.to_i.next : 1
    self.uuid = SecureRandom.hex(6) + next_id.to_s
  end

  private

    def added_message(message)
      self.update! last_responder: message.person, last_response_at: message.created_at
    end

end