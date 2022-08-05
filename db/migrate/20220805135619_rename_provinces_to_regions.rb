class RenameProvincesToRegions < ActiveRecord::Migration[6.1]
  def change
    rename_table :provinces, :regions
    rename_column :countries, :enable_province_management, :enable_regions
  end
end
