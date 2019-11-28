class AddPrimaryKeyToManagedRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :managed_records, :id, :primary_key
  end
end
