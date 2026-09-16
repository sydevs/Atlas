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

  desc 'Recompute finish_date for events whose stored value is out of date'
  task finish_dates: :environment do
    updated = 0
    skipped = []

    # Only events still treated as current can be visible, so they are the only
    # ones worth rewriting. Reuse the model's own callback rather than repeating
    # what it does, then write the result with update_column, which skips the
    # remaining callbacks: saving would also re-run the status machine, and an
    # event with an unusable recurrence may not even be valid.
    Event.current.in_batches.each_record do |event|
      begin
        event.send(:set_finish_date)
        next unless event.finish_date_changed?

        was = event.finish_date_was
        event.update_column :finish_date, event.finish_date
        updated += 1
        puts "Event ##{event.id}: #{was || 'never'} -> #{event.finish_date}"
      rescue StandardError => e
        # Eg. an event pointing at an area that no longer exists, which cannot
        # report a time zone and so cannot resolve its recurrence at all.
        skipped << event.id
        puts "Skipped event ##{event.id}: #{e.class}"
      end
    end

    puts "Updated #{updated} event(s)"
    puts "Skipped #{skipped.count} event(s) which could not be read: #{skipped.inspect}" if skipped.any?
  end
end
