class UpdateEmailTimestampFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :last_expiration_email_sent_at, :timestamp
    remove_column :events, :last_registration_email_sent_at, :timestamp
    add_column :events, :summary_email_sent_at, :timestamp
    add_column :managers, :summary_email_sent_at, :timestamp
  end
end
