class AddFollowupEmail < ActiveRecord::Migration[7.0]
  def change
    add_column :registrations, :reminder_sent_at, :datetime
    add_column :registrations, :followup_sent_at, :datetime
  end
end
