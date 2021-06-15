module ActivityMonitorable

  extend ActiveSupport::Concern

  included do
    before_save :update_activity_timestamps
    scope :active_since, ->(since) { where("#{table_name}.last_activity_on >= ?", since) }
    scope :inactive_since, ->(since) { where("#{table_name}.last_activity_on IS null OR #{table_name}.last_activity_on < ?", since) }
  end

  def last_activity_on
    self[:last_activity_on] || updated_at.to_date
  end

  def update_activity_timestamps(force = false)
    return unless force || changed?
    return if has_attribute?(:last_activity_on) && self[:last_activity_on].present? && self[:last_activity_on] >= Date.today

    if has_attribute?(:last_activity_on)
      if new_record?
        self.last_activity_on = Date.today
      else
        update_column(:last_activity_on, Date.today)
      end
    end
    
    parent.update_activity_timestamps(true) if respond_to?(:parent) && parent.respond_to?(:update_activity_timestamps)
  end

end
