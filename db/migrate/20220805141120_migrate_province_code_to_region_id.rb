class MigrateProvinceCodeToRegionId < ActiveRecord::Migration[6.1]
  def change
    add_reference :areas, :region

    Area.in_batches.each_record do |area|
      area.update_column :region_id, Region.find_by_province_code(area.province_code)&.id
    end
  end
end
