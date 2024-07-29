class Conversation < ApplicationRecord

  # Associations
  belongs_to :parent, polymorphic: true
  belongs_to :last_responder, polymorphic: true
  has_many :messages, class_name: 'Audit'

  # Scopes
  default_scope { active.order(last_response_at: :desc) }
  # scope :with_associations, -> { includes(:messages, :last_responder) }
  scope :active, -> { joins(:messages).group('conversations.id').having('count(CASE WHEN audits.category = ? THEN 1 END) > 0', Audit.categories[:email_forwarded]) }
  scope :open, -> { active.where(marked_complete_at: nil).or('marked_complete_at < last_response_at') }
  scope :awaiting_response, -> { open.where(last_responder_type: 'User') }

  # Methods
  delegate :managed_by?, to: :parent
  
  def open?
    marked_complete_at.nil? || marked_complete_at < last_response_at
  end
  
  def awaiting_response?
    open? && last_responder_type == 'User'
  end
  
  def members
    parent.conversation_members
  end

end