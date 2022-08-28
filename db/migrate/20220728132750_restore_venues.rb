class RestoreVenues < ActiveRecord::Migration[6.1]
  def up
    add_reference :events, :venue, index: true
    add_reference :events, :local_area, index: true
    add_column :venues, :address, :string
    add_index :venues, :place_id, unique: true

    Event.in_batches.each_record do |event|
      if event.location_type == 'Venue'
        event.update_columns({
          venue_id: event.location_id,
          local_area_id: event.location&.local_areas&.first
        })
      else
        event.update_column(:local_area_id, event.location_id)
      end
    end

    Venue.in_batches.each_record do |v|
      province_name = RegionDecorator.get_name(v.province_code, v.country_code)
      v.update_column(:address, [v[:street], v.city, province_name, v.country_code].compact.join(', '))
    end

    change_column :venues, :address, :string, null: false
  end

  def down
    remove_reference :events, :venue, index: true
    remove_reference :events, :local_area, index: true
    remove_column :venues, :address, :string
    remove_index :venues, :place_id, unique: true
  end
end
