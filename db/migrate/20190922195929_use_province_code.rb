  class UseProvinceCode < ActiveRecord::Migration[5.1]
  def change
    remove_column :provinces, :province_name, :string
    add_column :provinces, :province_code, :string, limit: 3
    remove_column :local_areas, :province_name, :string
    add_column :local_areas, :province_code, :string, limit: 3
    remove_column :venues, :province_name, :string
    add_column :venues, :province_code, :string, limit: 3
  end
end
