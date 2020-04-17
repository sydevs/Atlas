module Expirable

  extend ActiveSupport::Concern

  VERIFY_AFTER_WEEKS = 8
  ESCALATE_AFTER_WEEKS = 9
  EXPIRE_AFTER_WEEKS = 10
  ARCHIVE_AFTER_WEEKS = EXPIRE_AFTER_WEEKS + 1

  VERIFY_DATE = VERIFY_AFTER_WEEKS.weeks.ago.freeze
  ESCALATE_DATE = ESCALATE_AFTER_WEEKS.weeks.ago.freeze
  EXPIRE_DATE = EXPIRE_AFTER_WEEKS.weeks.ago.freeze
  ARCHIVE_DATE = ARCHIVE_AFTER_WEEKS.weeks.ago.freeze
=begin
  VERIFY_AFTER_MINUTES = 5
  ESCALATE_AFTER_MINUTES = 10
  EXPIRE_AFTER_MINUTES = 15

  VERIFY_DATE = VERIFY_AFTER_MINUTES.minutes.ago.freeze
  ESCALATE_DATE = ESCALATE_AFTER_MINUTES.minutes.ago.freeze
  EXPIRE_DATE = EXPIRE_AFTER_MINUTES.minutes.ago.freeze
  ARCHIVE_DATE = (EXPIRE_AFTER_MINUTES + 5).minutes.ago.freeze
=end
  included do
    scope :published, -> { where("#{table_name}.updated_at < ?", EXPIRE_DATE) }
    scope :needs_review, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", VERIFY_DATE, ARCHIVE_DATE) }
    scope :needs_urgent_review, -> { where("#{table_name}.updated_at < ? AND #{table_name}.updated_at > ?", ESCALATE_DATE, VERIFY_DATE) }
    scope :expired, -> { where("#{table_name}.updated_at <= ?", EXPIRE_DATE) }
    scope :recently_expired, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", EXPIRE_DATE, ARCHIVE_DATE) }
    scope :archived, -> { where("#{table_name}.updated_at <= ?", ARCHIVE_DATE) }
  end

  def needs_review_at
    updated_at + VERIFY_AFTER_WEEKS.weeks
    # updated_at + VERIFY_AFTER_MINUTES.minutes
  end

  def needs_escalation_at
    updated_at + ESCALATE_AFTER_WEEKS.weeks
    # updated_at + ESCALATE_AFTER_MINUTES.minutes
  end

  def expires_at
    updated_at + EXPIRE_AFTER_WEEKS.weeks
    # updated_at + EXPIRE_AFTER_MINUTES.minutes
  end

  def archives_at
    updated_at + ARCHIVE_AFTER_WEEKS.weeks
    # updated_at + ARCHIVE_AFTER_MINUTES.minutes
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
      updated_at < VERIFY_DATE
    else
      updated_at < ESCALATE_DATE
    end
  end

end
