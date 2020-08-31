module Expirable

  extend ActiveSupport::Concern

  VERIFY_AFTER_MINUTES = 1
  ESCALATE_AFTER_MINUTES = 2
  EXPIRE_AFTER_MINUTES = 3
  ARCHIVE_AFTER_MINUTES = 4

  VERIFY_AFTER_WEEKS = 8
  ESCALATE_AFTER_WEEKS = 9
  EXPIRE_AFTER_WEEKS = 10
  ARCHIVE_AFTER_WEEKS = EXPIRE_AFTER_WEEKS + 1

  included do
    scope :not_expired, -> { where("#{table_name}.updated_at > ?", Expirable.expire_date) }
    scope :needs_review, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", Expirable.verify_date, Expirable.archive_date) }
    scope :needs_urgent_review, -> { where("#{table_name}.updated_at < ? AND #{table_name}.updated_at > ?", Expirable.escalate_date, Expirable.verify_date) }
    scope :expired, -> { where("#{table_name}.updated_at <= ?", Expirable.expire_date) }
    scope :recently_expired, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", Expirable.expire_date, Expirable.archive_date) }
    scope :archived, -> { where("#{table_name}.updated_at <= ?", Expirable.archive_date) }
  end

  def self.verify_date
    # VERIFY_AFTER_WEEKS.weeks.ago
    VERIFY_AFTER_MINUTES.minutes.ago
  end

  def self.escalate_date
    # ESCALATE_AFTER_WEEKS.weeks.ago
    ESCALATE_AFTER_MINUTES.minutes.ago
  end

  def self.expire_date
    # EXPIRE_AFTER_WEEKS.weeks.ago
    EXPIRE_AFTER_MINUTES.minutes.ago
  end

  def self.archive_date
    # ARCHIVE_AFTER_WEEKS.weeks.ago
    ARCHIVE_AFTER_MINUTES.minutes.ago
  end

  def needs_review_at
    # updated_at + VERIFY_AFTER_WEEKS.weeks
    updated_at + VERIFY_AFTER_MINUTES.minutes
  end

  def needs_escalation_at
    # updated_at + ESCALATE_AFTER_WEEKS.weeks
    updated_at + ESCALATE_AFTER_MINUTES.minutes
  end

  def expires_at
    # updated_at + EXPIRE_AFTER_WEEKS.weeks
    updated_at + EXPIRE_AFTER_MINUTES.minutes
  end

  def archives_at
    # updated_at + ARCHIVE_AFTER_WEEKS.weeks
    updated_at + ARCHIVE_AFTER_MINUTES.minutes
  end

  def expired_at
    expires_at
  end

  def active?
    Time.now < expires_at
  end

  def updated?
    !expired? && !needs_review?
  end

  def expired?
    !active?
  end

  def archived?
    Time.now >= archives_at
  end

  def needs_review? urgency = :any
    if urgency == :urgent
      updated_at < Expirable.verify_date
    else
      updated_at < Expirable.escalate_date
    end
  end

end
