class AddEmailTimestamps < ActiveRecord::Migration[5.1]

  def change
    add_column :events, :registrations_sent_at, :datetime
    add_column :events, :latest_registration_at, :datetime
  end

end
