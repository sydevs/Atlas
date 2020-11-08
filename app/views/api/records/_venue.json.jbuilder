json.url api_venue_url(venue, format: :json)
json.map_url map_venue_url(venue)
json.extract! venue, :id, :label, :latitude, :longitude
json.address venue.address
json.address do
  json.building venue.name
  json.extract! venue, :street, :city, :province_code, :province_name, :country_code, :country_name, :postcode
end

if verbose
  json.events do
    json.partial! 'api/records/event', collection: venue.events, as: :event, verbose: false
  end
else
  json.events api_venue_events_url(venue.id, format: :json)
end

if venue.latitude? && venue.latitude?
  if @coordinates.present? && %w[address postcode].include?(@type)
    json.distance venue.distance(@coordinates)
    json.distance_text venue.distance_in_words(@coordinates)
  end

  if venue.place_id?
    json.directions_url "https://www.google.com/maps/search/?api=1&query=#{venue.address}>&query_place_id=#{venue.place_id}"
  else
    json.directions_url "http://www.google.com/maps/place/#{venue.latitude},#{venue.longitude}"
  end
end