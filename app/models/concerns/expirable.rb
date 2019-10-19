
module Expirable

  extend ActiveSupport::Concern

  VERIFY_AFTER_WEEKS = 8
  ESCALATE_AFTER_WEEKS = 9
  EXPIRE_AFTER_WEEKS = 10

  VERIFY_DATE = VERIFY_AFTER_WEEKS.weeks.ago.freeze
  ESCALATE_DATE = ESCALATE_AFTER_WEEKS.weeks.ago.freeze
  EXPIRE_DATE = EXPIRE_AFTER_WEEKS.weeks.ago.freeze
  RECENTLY_EXPIRED_DATE = (EXPIRE_AFTER_WEEKS + 1).weeks.ago.freeze

  included do
    scope :published, -> { where("#{self.table_name}.updated_at > ?", EXPIRE_DATE) }
    scope :needs_review, -> { where("#{self.table_name}.updated_at > ?", VERIFY_DATE) }
    scope :needs_urgent_review, -> { where("#{self.table_name}.updated_at > ? AND #{self.table_name}.updated_at <= ?", ESCALATE_DATE, VERIFY_DATE) }
    scope :expired, -> { where("#{self.table_name}.updated_at > ?", EXPIRE_DATE) }
    scope :recently_expired, -> { where("#{self.table_name}.updated_at <= ? AND #{self.table_name}.updated_at > ?", EXPIRE_DATE, RECENTLY_EXPIRED_DATE) }
  end

  def needs_verification_at
    updated_at + VERIFY_AFTER_WEEKS.weeks
  end

  def needs_escalation_at
    updated_at + ESCALATE_AFTER_WEEKS.weeks
  end

  def expires_at
    updated_at + EXPIRE_AFTER_WEEKS.weeks
  end

  def expired_at
    expires_at
  end

  def active?
    Time.now < expires_at
  end

  def expired?
    !active?
  end

  def needs_review? urgency = :any
    if urgency == :urgent
      updated_at > VERIFY_DATE
    else
      updated_at > ESCALATE_DATE
    end
  end
end
