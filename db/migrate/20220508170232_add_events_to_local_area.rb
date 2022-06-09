class AddEventsToLocalArea < ActiveRecord::Migration[6.1]
  def up
    add_column :events, :type, :string
    add_reference :events, :location, index: true, polymorphic: true

    Event.in_batches.each_record do |event| 
      event.update_columns({
        type: event[:online] ? 'OnlineEvent' : 'OfflineEvent',
        location_id: event[:online] ? Venue.find_by_id(event.venue_id)&.local_areas&.first&.id : event.venue_id,
        location_type: event[:online] ? 'LocalArea' : 'Venue',
      })
    end

    remove_reference :events, :venue, index: true
  end

  def down
    add_reference :events, :venue, index: true

    Event.in_batches.each_record do |event| 
      event.update_columns({
        online: event.type == 'OnlineEvent',
        venue_id: event.location_id,
      })
    end

    remove_reference :events, :location, index: true, polymorphic: true
    remove_column :events, :type
  end
end
