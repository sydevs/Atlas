class AddTimestampsToManagedRecords < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :managed_records, null: false, default: -> { 'NOW()' }
  end
end
