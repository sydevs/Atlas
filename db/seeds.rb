
if Rails.env.production?
  puts "Seeding cannot be run in production!"
end

20.times do |id|
  venue = Venue.find_or_initialize_by(id: id)
  venue.update!({
    name: [true, false].sample ? Faker::Address.community : nil,
    latitude: Faker::Address.latitude,
    longitude: Faker::Address.longitude,
    contact_email: Faker::Internet.safe_email,
    address_street: Faker::Address.street_address,
    address_municipality: Faker::Address.city,
    address_subnational: Faker::Address.state,
    address_country: Faker::Address.country,
    address_postcode: Faker::Address.zip,
  })

  venue.events.destroy_all

  puts "Created Venue - #{venue.label}"

  [1, 1, 1, 2, 2, 3, 4, 5].sample.times do
    start_hour = rand(10..20)
    start_minute = [0, 15, 30, 45].sample
    start_date = Faker::Date.between(from: 1.month.ago, to: 1.year.from_now)

    event = venue.events.create!({
      name: [true, false].sample ? Faker::Address.community : nil,
      description: [true, false].sample ? Faker::Lorem.paragraph : nil,
      contact_email: [true, true, false].sample ? Faker::Internet.safe_email : nil,
      room: [true, false].sample ? "#{Faker::Address.city_prefix} Room" : nil,
      start_date: start_date,
      end_date: Faker::Date.between(from: start_date, to: 6.months.since(start_date)),
      start_time: "#{start_hour}:#{sprintf '%02d', start_minute}",
      end_time: "#{start_hour + [0, 1, 1, 2].sample}:#{sprintf '%02d', [start_minute, start_minute, 0, 15, 30, 45].sample}",
      recurrence: Event.recurrences.keys.sample,
      category: Event.categories.keys.sample,
    })

    puts " |-> Created Event - #{event.label}"
    next unless [true, true, false].sample

    rand(10..20).times do
      registration = event.registrations.create!({
        name: Faker::Name.name,
        email: Faker::Internet.safe_email,
        comment: [true, false].sample ? Faker::Lorem.paragraph : nil,
        created_at: Faker::Time.backward(days: 14),
      })

      puts "    |-> Created Registration - #{registration.name} <#{registration.email}>"
    end
  end
end
