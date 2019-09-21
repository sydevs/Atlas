class CreateManageableTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :managed_regions, :managed_records
    rename_column :managed_records, :region_type, :record_type
    rename_column :managed_records, :region_id, :record_id
  end
end
