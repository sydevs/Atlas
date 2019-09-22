
IMAGE_SETS = {
  concert: 2,
  public_event: 2,
  other: 6,
}.freeze

if Rails.env.production?
  puts "Seeding cannot be run in production!"
  return
end

def load_manager name
  manager = Manager.find_or_initialize_by(email: params[:email])
  manager.name = params[:name] if params[:name].present?
  manager.save!
end

def load_country country_code
  country = Country.find_or_initialize_by(country_code: country_code)
  if country.new_record?
    country.managers = MANAGERS.sample(rand(0..4))
    country.save!
  end

  country_code
end

def load_province province_name, country_code
  province = Province.find_or_initialize_by(province_name: province_name, country_code: country_code)
  if province.new_record?
    province.managers = MANAGERS.sample(rand(0..4))
    province.save!
  end

  province_name
end

def load_venue address, country_code, index
  address = address.split(', ')
  contact = "#{Faker::Name.first_name} #{Faker::Name.last_name}"

  venue = Venue.find_or_initialize_by(street: address[0])
  venue.update!({
    name: [true, false].sample ? Faker::Address.community : nil,
    street: address[0],
    city: address[1],
    country_code: load_country(country_code),
    province_name: load_province(address[2], country_code),
    postcode: address[3],
    latitude: address[4],
    longitude: address[5],
  })
  venue.managers = [MANAGERS.sample]
  venue.save!

  venue.events.destroy_all

  puts "Created Venue #{index} - #{venue.label}"

  [1, 1, 1, 2, 2, 3, 4, 5].sample.times do
    start_hour = rand(10..20)
    start_minute = [0, 15, 30, 45].sample
    start_date = Faker::Date.between(from: 1.month.ago, to: 1.year.from_now)
    contact = [true, true, false].sample ? "#{Faker::Name.first_name} #{Faker::Name.last_name}" : nil
    category = Event.categories.keys.sample
    images_folder = %i[concert public_event].include?(category) ? category : :other
    images_folder = "db/seeds/files/#{images_folder}/#{rand(1..IMAGE_SETS[images_folder])}"

    event = venue.events.create!({
      name: [true, false].sample ? Faker::Address.community : nil,
      description: [true, false].sample ? Faker::Lorem.paragraph : nil,
      room: [true, false].sample ? "#{Faker::Address.city_prefix} Room" : nil,
      start_date: start_date,
      end_date: [true, false].sample ? Faker::Date.between(from: start_date, to: 6.months.since(start_date)) : nil,
      start_time: "#{start_hour}:#{sprintf '%02d', start_minute}",
      end_time: [true, true, false].sample ? "#{start_hour + [0, 1, 1, 2].sample}:#{sprintf '%02d', [start_minute, start_minute, 0, 15, 30, 45].sample}" : nil,
      languages: [true, false].sample ? %w[EN] : [I18nData.languages.keys.sample],
      recurrence: Event.recurrences.keys.sample,
      category: category,
      images: Dir.glob("#{images_folder}/*.jpg").map { |f| File.open(f, 'r') },
    })

    if [true, false].sample
      event.managers << MANAGERS.sample
      event.save!
    end

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

MANAGERS = Manager.limit(10).to_a

MANAGERS.count.upto(10).each do |index|
  name = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
  email = "#{name.parameterize(separator: '_')}@example.com"
  MANAGERS << Manager.create(name: name, email: email)
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

local_area = LocalArea.find_or_initialize_by(identifier: 'nyc')
if local_area.new_record?
  local_area.update!({
    name: 'Tri-State Area (NYC)',
    latitude: 40.730610,
    longitude: -73.935242,
    radius: 30,
    country_code: load_country('US'),
  })
end

local_area = LocalArea.find_or_initialize_by(identifier: 'benelux')
if local_area.new_record?
  local_area.update!({
    name: 'Benelux',
    latitude: 51.260197,
    longitude: 4.402771,
    radius: 240,
  })
end

local_area = LocalArea.find_or_initialize_by(identifier: 'boston')
if local_area.new_record?
  local_area.update!({
    name: 'Boston',
    latitude: 42.361145,
    longitude: -71.057083,
    radius: 25,
    province_name: load_province('Massachusetts'),
    country_code: load_country('US'),
  })
end
