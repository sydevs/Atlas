class AddMailTimestamps < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :last_expiration_email_sent_at, :timestamp
    add_column :events, :last_registration_email_sent_at, :timestamp
    remove_column :events, :registrations_sent_at, :timestamp
  end
end
