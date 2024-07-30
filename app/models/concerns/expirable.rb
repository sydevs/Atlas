module Expirable

  extend ActiveSupport::Concern

  if ENV['TEST_EMAILS']
    TRANSITION_STATE_AFTER = {
      should_verify: 0.minutes,
      should_need_review: 10.minutes,
      should_need_urgent_review: 19.minutes,
      should_need_immediate_review: 25.minutes,
      should_expire: 28.minutes,
      should_archive: 37.minutes,
    }.freeze
  else
    TRANSITION_STATE_AFTER = {
      should_verify: 0.weeks,
      should_need_review: 12.weeks,
      should_need_urgent_review: 13.weeks,
      should_need_immediate_review: 14.weeks - 1.day,
      should_expire: 14.weeks,
      should_archive: 16.weeks,
    }.freeze
  end

  REVIEWABLE_STATES = %i[needs_review needs_urgent_review needs_immediate_review expired]
  PUBLISHABLE_STATES = %i[verified needs_review needs_urgent_review needs_immediate_review]

  included do
    enum status: {
      verified: 0,
      needs_review: 1,
      needs_urgent_review: 2,
      needs_immediate_review: 6,
      expired: 3,
      archived: 4,
      finished: 5,
    }, _scopes: false

    aasm column: :status, enum: true, skip_validation_on_save: true, whiny_transitions: false do
      state :verified, initial: true
      state :needs_review
      state :needs_urgent_review
      state :needs_immediate_review
      state :expired
      state :archived
      state :finished

      after_all_events :update_timestamps
      after_all_events :record_status_audit!

      event :update_status, after_enter: :log_event do
        transitions to: :finished, if: :should_finish?
        transitions from: :verified, to: :needs_review, if: :should_need_review?
        transitions from: :needs_review, to: :needs_urgent_review, if: :should_need_urgent_review?
        transitions from: :needs_urgent_review, to: :needs_immediate_review, if: :should_need_immediate_review?
        transitions from: :needs_immediate_review, to: :expired, if: :should_expire?
        transitions from: :expired, to: :archived, if: :should_archive?, after: Proc.new { update_column(:verification_streak, 0) }
        
        after_commit { try(:log_status_change) }
      end

      event :reset_status do
        transitions to: :finished, if: :should_finish?
        transitions to: :archived, if: :should_archive?
        transitions to: :expired, if: :should_expire?, after: Proc.new { update_column(:verification_streak, 0) }
        transitions to: :needs_urgent_review, if: :should_need_urgent_review?
        transitions to: :needs_immediate_review, if: :should_need_immediate_review?
        transitions to: :needs_review, if: :should_need_review?
        transitions to: :verified, unless: :verified?
      end

      event :verify do
        after do
          unless new_record?
            increment(:verification_streak)
            touch
          end
        end

        transitions to: :verified, if: Proc.new { finished? && !should_finish? }
        transitions to: :verified, unless: Proc.new { finished? || verified? }
      end

      event :expire do
        transitions to: :expired, unless: :expired?, after: Proc.new { update_column(:verification_streak, 0) }
      end
    end

    TRANSITION_STATE_AFTER.keys.each do |key|
      define_method :"#{key}_at" do
        expiration_base = self.try(:expiration_base) || TRANSITION_STATE_AFTER[:should_need_review]
        waiting_period = expiration_base + TRANSITION_STATE_AFTER[key] - TRANSITION_STATE_AFTER[:should_need_review]
        result = (updated_at || 1.minute.ago) + waiting_period
        ENV['TEST_EMAILS'] ? result : result.beginning_of_hour
      end

      define_method :"#{key}?" do
        send(:"#{key}_at") <= Time.now
      end
    end

    before_save :verify

    scope :needs_review, -> { where(status: REVIEWABLE_STATES) }
    scope :publishable, -> { where(status: PUBLISHABLE_STATES) }
    scope :unpublishable, -> { where(status: Event.statuses.keys.map(&:to_sym) - PUBLISHABLE_STATES) }
  end

  def update_timestamps
    if new_record?
      self.should_update_status_at = should_need_review_at
    elsif archived? || finished?
      update_column :should_update_status_at, nil
    else
      next_state_index = self.class.statuses[status] + 1
      next_state = TRANSITION_STATE_AFTER.keys[next_state_index]
      update_column :should_update_status_at, send(:"#{next_state}_at")
    end

    if new_record?
      self.verified_at = Time.now
    elsif respond_to?("#{status}_at")
      update_column "#{status}_at", Time.now
    end
  end

  def publishable?
    PUBLISHABLE_STATES.include?(status.to_sym)
  end

  def reviewable?
    REVIEWABLE_STATES.include?(status.to_sym)
  end

end
