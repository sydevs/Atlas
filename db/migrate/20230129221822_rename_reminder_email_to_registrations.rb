class RenameReminderEmailToRegistrations < ActiveRecord::Migration[6.1]
  def change
    rename_column :events, :reminder_email_sent_at, :registrations_email_sent_at
  end
end
