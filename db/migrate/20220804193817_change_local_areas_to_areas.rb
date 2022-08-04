class ChangeLocalAreasToAreas < ActiveRecord::Migration[6.1]
  def change
    rename_table :local_areas, :areas
    rename_table :local_area_venues, :area_venues

    rename_column :events, :local_area_id, :area_id
    rename_column :area_venues, :local_area_id, :area_id
  end
end
