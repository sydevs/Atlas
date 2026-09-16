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

  desc 'Hide events whose recurrence never produces an occurrence'
  task finish_dates: :environment do
    updated = 0

    # Only events still treated as current can be visible, so they are the only
    # ones worth rewriting. update_column skips callbacks and validations, which
    # matters because an event with an unusable recurrence may not be valid.
    Event.current.in_batches.each_record do |event|
      next if event.recurrence.nil? || event.occurs?

      event.update_column :finish_date, 1.day.ago
      updated += 1
      puts "Hiding event ##{event.id} (#{event.recurrence_start_date} to #{event.recurrence_end_date})"
    end

    puts "Hid #{updated} event(s) which never occur"
  end
end
