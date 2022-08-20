class AddUnspecifiedAreaToForVenues < ActiveRecord::Migration[6.1]
  def up
    Country.all.each do |country|
      events = country.events.where(local_area_id: nil).where.not(venue_id: nil)
      puts "No missing local areas in #{country.country_code}" && next unless events.present?

      local_area = country.local_areas.create_with({
        latitude: 51.477928,
        longitude: -0.001545,
        radius: 0,
        time_zone: "Europe/London",
      }).find_or_create_by!(name: "Unspecified Area")

      events.update_all(local_area_id: local_area.id)
      puts "Add #{events.count} event(s) to Unspecified Area, #{country.country_code} (#{local_area.id})"
    end
  end
end
