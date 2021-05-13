class AddEmailTimestampToEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :reminder_emails_sent_at, :timestamp
  end
end
