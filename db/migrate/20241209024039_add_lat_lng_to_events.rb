class AddLatLngToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :latitude, :float
    add_column :events, :longitude, :float

    reversible do |dir|
      dir.up do
        Event.in_batches do |events|
          events.each do |event|
            event.update(latitude: event.location.latitude, longitude: event.location.longitude) if event.location.present?
          end
        end
      end
    end
  end
end
