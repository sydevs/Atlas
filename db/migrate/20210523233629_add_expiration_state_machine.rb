class AddExpirationStateMachine < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :should_update_status_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :events, :verified_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :events, :expired_at, :datetime
    add_column :events, :archived_at, :datetime
    add_column :events, :finished_at, :datetime

    add_column :events, :status, :integer, default: 0, null: false
    add_index :events, :status
  end
end
