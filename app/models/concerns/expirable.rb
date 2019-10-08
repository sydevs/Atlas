
module Expirable

  extend ActiveSupport::Concern

  RECENT_EXPIRATION_DATE = 11.weeks.ago.freeze
  EXPIRATION_DATE = 10.weeks.ago.freeze
  ESCALATE_DATE = 9.weeks.ago.freeze
  VERIFY_DATE = 8.weeks.ago.freeze

  included do
    scope :published, -> { where('updated_at > ?', EXPIRATION_DATE) }
    scope :needs_review, -> { where('updated_at > ?', VERIFY_DATE) }
    scope :needs_urgent_review, -> { where('updated_at > ? AND updated_at <= ?', ESCALATE_DATE, VERIFY_DATE) }
    scope :expired, -> { where('updated_at <= ?', EXPIRATION_DATE) }
    scope :recently_expired, -> { where('updated_at <= ? AND updated_at > ?', EXPIRATION_DATE, RECENT_EXPIRATION_DATE) }
  end

  def active?
    updated_at > EXPIRATION_DATE
  end

  def expired?
    !active?
  end

  def needs_review? urgency = :any
    if urgency = :urgent
      updated_at > VERIFY_DATE
    else
      updated_at > ESCALATE_DATE
    end
  end
end
