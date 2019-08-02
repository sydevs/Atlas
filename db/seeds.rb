
if Rails.env.production?
  puts "Seeding cannot be run in production!"
  return
end

def load_venue address, country_code, index
  address = address.split(', ')
  contact = "#{Faker::Name.first_name} #{Faker::Name.last_name}"

  venue = Venue.find_or_initialize_by(street: address[0])
  venue.update!({
    name: [true, false].sample ? Faker::Address.community : nil,
    contact_name: contact,
    contact_email: "#{contact.parameterize(separator: '_')}@example.com",
    street: address[0],
    municipality: address[1],
    subnational: address[2],
    country_code: country_code,
    postcode: address[3],
    latitude: address[4],
    longitude: address[5],
  })

  venue.events.destroy_all

  puts "Created Venue #{index} - #{venue.label}"

  [1, 1, 1, 2, 2, 3, 4, 5].sample.times do
    start_hour = rand(10..20)
    start_minute = [0, 15, 30, 45].sample
    start_date = Faker::Date.between(from: 1.month.ago, to: 1.year.from_now)
    contact = [true, true, false].sample ? "#{Faker::Name.first_name} #{Faker::Name.last_name}" : nil

    event = venue.events.create!({
      name: [true, false].sample ? Faker::Address.community : nil,
      description: [true, false].sample ? Faker::Lorem.paragraph : nil,
      contact_name: contact,
      contact_email: contact ? "#{contact.parameterize(separator: '_')}@example.com" : nil,
      room: [true, false].sample ? "#{Faker::Address.city_prefix} Room" : nil,
      start_date: start_date,
      end_date: [true, false].sample ? Faker::Date.between(from: start_date, to: 6.months.since(start_date)) : nil,
      start_time: "#{start_hour}:#{sprintf '%02d', start_minute}",
      end_time: [true, true, false].sample ? "#{start_hour + [0, 1, 1, 2].sample}:#{sprintf '%02d', [start_minute, start_minute, 0, 15, 30, 45].sample}" : nil,
      languages: [true, false].sample ? %w[EN] : [I18nData.languages.keys.sample],
      recurrence: Event.recurrences.keys.sample,
      category: Event.categories.keys.sample,
    })

    puts " |-> Created Event - #{event.label}"
    next unless [true, true, false].sample

    rand(10..20).times do
      name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
      registration = event.registrations.create!({
        name: name,
        email: "#{name.parameterize(separator: '_')}@example.com",
        comment: [true, false].sample ? Faker::Lorem.paragraph : nil,
        created_at: Faker::Time.backward(days: 14),
      })

      puts "    |-> Created Registration - #{registration.name} <#{registration.email}>"
    end
  end
end

counter = 1
File.open('db/seeds/us.addresses.txt', 'r').each_line do |line|
  load_venue(line, 'US', counter)
  counter += 1
end

File.open('db/seeds/uk.addresses.txt', 'r').each_line do |line|
  load_venue(line, 'GB', counter)
  counter += 1
end
