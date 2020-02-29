json.url api_event_url(event, format: :json)
json.map_url map_event_url(event)
json.extract! event, :id, :label
json.description event.description || ''

if event.venue.present?
  json.address_text [event.room, event.venue.name, event.venue.full_address].compact.join(', ')

  if verbose
    json.address do
      json.extract! event, :room
      json.extract! event.venue, :street, :city, :province_code, :province_name, :country_code, :country_name, :postcode
    end
  end

  json.venue_id event.venue_id if event.venue_id
  
  if event.venue.latitude? && event.venue.latitude?
    json.latitude event.venue.latitude
    json.longitude event.venue.longitude

    if @coordinates.present? && %w[address postcode].include?(@type)
      json.distance event.venue.distance(@coordinates)
      json.distance_text event.venue.distance_in_words(@coordinates)
    end

    if event.venue.place_id?
      json.directions_url "https://www.google.com/maps/search/?api=1&query=#{event.venue.full_address}>&query_place_id=#{event.venue.place_id}"
    else
      json.directions_url "http://www.google.com/maps/place/#{event.venue.latitude},#{event.venue.longitude}"
    end
  end
end

if event.language
  json.language_code event.language
  json.language I18nData.languages(I18n.locale)[event.language].split(/[,;]/)[0]
end

json.category do
  json.id event.category
  json.name event.category_name
  json.description event.category_description
end

json.upcoming_dates event.upcoming_dates.map(&:to_s)

json.recurrence_in_words event.recurrence_in_words
json.formatted_start_end_time event.formatted_start_end_time
json.timing_text event.timing_in_words
json.timing do
  json.description event.timing_description
  json.extract! event, :recurrence, :start_date, :end_date, :start_time, :end_time
end

json.registration do
  json.mode event.registration_mode
  json.label translate('map.registration.action', service: translate_enum_value(event, :registration_mode))
  json.url event.registration_url
end

json.images do
  json.array! event.pictures do |picture|
    json.url picture.file.url
    json.thumbnail_url picture.file.url(:thumbnail)
  end
end

if verbose
  json.venue do
    json.partial! 'api/records/venue', venue: event.venue, verbose: false
  end
else
  json.venue api_venue_url(event.venue_id, format: :json)
end
