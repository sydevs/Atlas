class AddTimeZoneToLocalArea < ActiveRecord::Migration[6.1]
  def change
    add_column :local_areas, :time_zone, :string

    LocalArea.in_batches.each_record do |local_area| 
      local_area.update_columns(time_zone: Timezone.lookup(local_area.latitude, local_area.longitude).to_s)
    end
  end
end
