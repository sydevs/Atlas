class RenameVenueProvinceColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :venues, :province, :province_name
  end
end
