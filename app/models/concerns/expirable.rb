
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
    scope :published, -> { where('updated_at > ?', EXPIRE_DATE) }
    scope :needs_review, -> { where('updated_at > ?', VERIFY_DATE) }
    scope :needs_urgent_review, -> { where('updated_at > ? AND updated_at <= ?', ESCALATE_DATE, VERIFY_DATE) }
    scope :expired, -> { where('updated_at <= ?', EXPIRE_DATE) }
    scope :recently_expired, -> { where('updated_at <= ? AND updated_at > ?', EXPIRE_DATE, RECENTLY_EXPIRED_DATE) }
  end

  def verification_date
    updated_at + VERIFY_AFTER_WEEKS.weeks
  end

  def escalation_date
    updated_at + ESCALATE_AFTER_WEEKS.weeks
  end

  def expiration_date
    updated_at + EXPIRE_AFTER_WEEKS.weeks
  end

  def active?
    updated_at > EXPIRATION_DATE
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
