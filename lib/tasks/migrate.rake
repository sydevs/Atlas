namespace :migrate do
  desc 'Add unspecified area to any events which are missing them'
  task :areas, [:id] => :environment do |_, args|
    Country.all.each do |country|
      events = country.events.where(area_id: nil).where.not(venue_id: nil)
      puts "No missing areas in #{country.country_code}" && next unless events.present?

      center = country.polygons[0].centroid
      area = country.areas.create_with({
        latitude: center.lat,
        longitude: center.lng,
        radius: 0,
        time_zone: "Europe/London",
      }).find_or_create_by(name: "Unspecified Area")
      area.save!(validate: false)

      events.update_all(area_id: area.id)
      puts "Add #{events.count} event(s) to Unspecified Area, #{country.country_code} (#{area.id})"
    end
  end
end
