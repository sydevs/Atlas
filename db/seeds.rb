IMAGE_SETS = {
  concert: 2,
  festival: 2,
  other: 6,
}.freeze

if Rails.env.production? && !ENV['force']
  puts 'Seeding cannot be run in production!'
  return
end

def get_time_zone country_code
  case country_code
  when 'US'
    'America/New_York'
  when 'GB'
    'Europe/London'
  end
end

def load_country name, country_code, osm_id
  country = Country.find_or_initialize_by(country_code: country_code)
  if country.new_record?
    country.osm_id = osm_id
    country.fetch_geo_data!
    country.assign_attributes(name: name, country_code: country_code)
    country.save!

    country.managers = MANAGERS.sample(rand(0..2))
    country.save!
  end

  country
end

def load_region name, country_code, osm_id
  country = Country.find_by_country_code(country_code)
  region = country.regions.find_or_initialize_by(osm_id: osm_id)

  if region.new_record?
    region.fetch_geo_data!
    region.assign_attributes(name: name)
    region.save!

    region.managers = MANAGERS.sample(rand(0..2))
    region.save!
  end

  region
end

def load_area name, region_name, place_id
  region = Region.find_by_name(region_name)
  area = region.areas.find_or_initialize_by(name: name)

  if area.new_record?
    area.assign_attributes(name: name)
    geo_data = GoogleMapsAPI.fetch_area(placeid: place_id)
    area.assign_attributes(geo_data)
    area.save!

    area.managers = MANAGERS.sample(rand(0..1))
    area.save!
  end

  load_events [1, 1, 1, 2, 3].sample, area

  area
end

def load_venue street, city, post_code, place_id
  contact = "#{Faker::Name.first_name} #{Faker::Name.last_name}"

  area = Area.find_by_name(city)
  venue = area.venues.find_or_initialize_by(street: street)
  geo_data = GoogleMapsAPI.fetch_place(placeid: place_id, language: 'en', sessiontoken: SESSION_ID)
  venue.assign_attributes(geo_data)

  venue.assign_attributes({
    name: [true, false, false].sample ? Faker::Address.community : nil,
    street: street,
    city: city,
    post_code: post_code,
  })

  venue.save!
  venue.events.destroy_all
  load_events [1, 1, 1, 2, 3, 5].sample, area, venue

  venue
end

def load_events count, area, venue = nil
  count.times do
    start_hour = rand(10..20)
    start_minute = [0, 15, 30, 45].sample
    start_date = Faker::Date.between(from: 1.month.ago, to: 1.year.from_now)
    contact = [true, true, false].sample ? "#{Faker::Name.first_name} #{Faker::Name.last_name}" : nil
    category = Event.categories.keys.sample
    images_folder = %i[concert festival].include?(category) ? category : :other
    images_folder = "db/seeds/files/#{images_folder}/#{rand(1..IMAGE_SETS[images_folder])}"
    online = venue.nil?

    event = area.events.new({
      published: true,
      type: online ? 'OnlineEvent' : 'OfflineEvent',
      custom_name: [true, false].sample ? Faker::Address.community : nil,
      description: [true, false].sample ? Faker::Lorem.paragraph : nil,
      room: [true, false, false].sample ? "#{Faker::Address.city_prefix} Room" : nil,
      start_date: start_date,
      end_date: Faker::Date.between(from: start_date, to: 6.months.since(start_date)),
      start_time: "#{start_hour}:#{format '%02d', start_minute}",
      end_time: "#{start_hour + [0, 1, 1, 2].sample}:#{format '%02d', start_minute + [15, 30, 45].sample}",
      language_code: %w[EN EN EN IT IT DE].sample,
      recurrence: Event.recurrences.keys.sample,
      online_url: ("www.example.com" if online),
      category: category,
      venue: venue,
      # pictures_attributes: Dir.glob("#{images_folder}/*.jpg").map { |f| { file: File.open(f, 'r') } },
    })

    event.manager = MANAGERS.sample
    event.save!

    puts " |-> Created Event - #{event.custom_name || "#{event.category.titleize} at #{event.venue&.street || event.area.name}"}"
    next unless [true, true, false].sample

    @event = event

    rand(5..15).times do
      first_name = Faker::Name.first_name
      name = "#{first_name} #{Faker::Name.last_name}"
      question_count = [0, 0, 0, 1, 1, 2, 2, 3, 4].sample
      registration = event.registrations.create!({
        name: name,
        email: "#{first_name.parameterize}@example.com",
        questions: Event.registration_questions.keys.sample(question_count).map { |q| [q, Faker::Lorem.paragraph] }.to_h,
        created_at: Faker::Time.backward(days: 14),
        starting_at: event.start_date,
      })

      puts "    |-> Created Registration - #{registration.name} <#{registration.email}>"
    end
  end
end

SESSION_ID = SecureRandom.hex(16)

# CREATE MANAGERS
MANAGERS = Manager.limit(10).to_a

MANAGERS.count.upto(10).each do
  name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
  email = "#{name.split(' ').first.parameterize}@example.com"
  manager = Manager.create({
    name: name,
    email: email,
    language_code: 'en',
    email_verification_sent_at: Time.now,
  })

  manager.update_column :email_verified, true
  MANAGERS << manager
end

Manager.find_or_create_by(email: "admin@example.com") do |manager|
  manager.name = 'Test Admin'
  manager.administrator = true
  manager.language_code = 'en'
  manager.email_verified = true
  manager.email_verification_sent_at = Time.now
end

# CREATE PLACES & EVENTS
File.open('db/seeds/places.txt', 'r').each_line do |line|
  parts = line.split(', ').map(&:strip)
  puts "Creating #{line}"
  send("load_#{parts[0].downcase}", *parts.drop(1))
end
