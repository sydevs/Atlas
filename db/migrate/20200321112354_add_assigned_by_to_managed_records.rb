class AddAssignedByToManagedRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :managed_records, :assigned_by_id, :integer
  end
end
