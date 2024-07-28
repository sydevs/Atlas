module HasActivity

  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :channel
    # Create a scope which left outer joins with the last message and compare the ID to the manager id
    # scope :message_outstanding, -> { where('events.finish_date IS NULL OR events.finish_date >= ?', DateTime.now) }
    
    after_commit :record_update_activity!
  end

  private

    def record_update_activity!
      # return unless current_user.present?

      puts "RECORD ACTIVITY? #{Current.user}"
      activity = activities.new({
        category: :record_updated,
        channel: self,
        account: Current.user,
        data: {
          status_change: status_changed? ? self.status : nil,
          changes: self.saved_changes,
        }
      })

      puts "RECORD ACTIVITY"
      pp activity.save!
      pp activity
      true
    end

end