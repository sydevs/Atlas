module Expirable

  extend ActiveSupport::Concern

  TEST_MODE = true

  BASE_DURATION = TEST_MODE ? 5 : 8
  DURATION_INCREMENT = TEST_MODE ? 7 : 1

  LEVELS = {
    verify: 0,
    escalate: 1,
    expire: 2,
    archive: 3
  }.freeze

  included do
    scope :not_expired, -> { where("#{table_name}.updated_at > ?", Expirable.date_for(:expire)) }
    scope :needs_review, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", Expirable.date_for(:verify), Expirable.date_for(:archive)) }
    scope :needs_urgent_review, -> { where("#{table_name}.updated_at < ? AND #{table_name}.updated_at > ?", Expirable.date_for(:escalate), Expirable.date_for(:verify)) }
    scope :expired, -> { where("#{table_name}.updated_at <= ?", Expirable.date_for(:expire)) }
    scope :recently_expired, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", Expirable.date_for(:expire), Expirable.date_for(:archive)) }
    scope :archived, -> { where("#{table_name}.updated_at <= ?", Expirable.date_for(:archive)) }
  end

  def self.count_for(level)
    return DURATION_INCREMENT if level == :interval
    
    BASE_DURATION + (LEVELS[level] * DURATION_INCREMENT)
  end

  def self.duration_for(level)
    base = Expirable.count_for(level)
    TEST_MODE ? base.minutes : base.weeks
  end

  def self.date_for(level)
    Expirable.duration_for(level).ago
  end

  def needs_review_at
    updated_at + Expirable.duration_for(:verify)
  end

  def needs_escalation_at
    updated_at + Expirable.duration_for(:escalate)
  end

  def expires_at
    updated_at + Expirable.duration_for(:expire)
  end

  def archives_at
    updated_at + Expirable.duration_for(:archive)
  end

  def expired_at
    expires_at
  end

  def updated?
    !expired? && !needs_review?
  end

  def expired?
    !active?
  end

  def recently_expired?
    expired? && !archived?
  end

  def active?
    Time.now < expires_at
  end

  def archived?
    Time.now >= archives_at
  end

  def needs_review?
    Time.now >= needs_review_at
  end

  def needs_urgent_review?
    Time.now >= needs_escalation_at
  end

end
