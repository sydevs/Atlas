module Audited

  extend ActiveSupport::Concern

  EXCLUDED_COLUMNS = %w[
    updated_at created_at
    summary_email_sent_at status_email_sent_at latest_registration_at
    should_update_status_at verified_at expired_at archived_at finished_at
    last_login_at
    summary_metadata
    status verification_streak
  ]

  included do
    has_many :audits, as: :parent, dependent: :delete_all
    # Create a scope which left outer joins with the last message and compare the ID to the manager id
    # scope :message_outstanding, -> { where('events.finish_date IS NULL OR events.finish_date >= ?', DateTime.now) }
    
    after_commit :record_update_audit!
    after_commit :record_status_audit!, if: :status_previously_changed?
  end

  def record_status_audit!
    audits.create!({
      category: status.to_sym == :verified ? :status_verified : :status_change,
      parent: self,
      person: Current.user,
      data: {
        status: status,
      }
    })
  end

  private

    def record_update_audit!
      return unless Current.user.present?

      changes = saved_changes.reject { |k, v| EXCLUDED_COLUMNS.include?(k) }
      return unless changes.present?

      audits.create!({
        category: id_previously_changed? ? :record_created : :record_updated,
        parent: self,
        person: Current.user,
        data: {
          changes: changes,
        }
      })
    end

end