json.url api_venue_url(venue, format: :json)
json.map_url map_root_url(venue: venue.id)
json.extract! venue, :id, :label, :latitude, :longitude
json.address_text venue.full_address
json.address do
  json.extract! venue, :street, :city, :province_code, :province_name, :country_code, :country_name, :postcode
end

if verbose
  json.events do
    json.partial! 'api/records/event', collection: venue.events, as: :event, verbose: false
  end
else
  json.events api_venue_events_url(venue.id, format: :json)
end

if venue.latitude? && venue.latitude? && @coordinates.present?
  json.distance venue.distance(@coordinates)
  json.distance_text venue.distance_in_words(@coordinates)
end