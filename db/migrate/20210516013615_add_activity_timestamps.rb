class AddActivityTimestamps < ActiveRecord::Migration[6.1]
  def change
    rename_column :events, :reminder_emails_sent_at, :reminder_email_sent_at
    add_column :venues, :last_activity_on, :date
    add_column :local_areas, :last_activity_on, :date
    add_column :provinces, :last_activity_on, :date
    add_column :countries, :last_activity_on, :date
  end
end
