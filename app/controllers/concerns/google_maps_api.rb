require 'httparty'

## AUTOCOMPLETE
# This concern simplifies requests to geocode addresses

module GoogleMapsAPI

  def self.predict parameters
    parameters.merge!({
      key: ENV.fetch('GOOGLE_PLACES_API_KEY'),
    })

    url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?#{parameters.to_query}"
    response = HTTParty.get(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })
    puts "#{url} - #{response.pretty_inspect}"

    if response['predictions'].length > 0
      {
        results: response['predictions'].each do |prediction|
          {
            place_id: prediction['place_id'],
            title: prediction['description'],
            name: prediction['structured_formatting']['main_text'],
            address: prediction['structured_formatting']['secondary_text'],
          }
        end
      }
    elsif response['status'] == 'ZERO_RESULTS'
      { results: [] }
    else
      nil
    end
  end

  def self.fetch_place parameters
    parameters.merge!({
      key: ENV.fetch('GOOGLE_PLACES_API_KEY'),
      fields: 'geometry',
    })

    url = "https://maps.googleapis.com/maps/api/place/details/json?#{parameters.to_query}"
    response = HTTParty.get(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })

    if response['result'].present?
      geometry = response['result']['geometry']
      v = response['result']['geometry']['viewport']
      center = Geokit::LatLng.normalize(geometry['location']['lat'], geometry['location']['lng'])

      {
        latitude: center.lat,
        longitude: center.lng,
      }
    else
      nil
    end
  end

  def self.fetch_area parameters
    parameters.merge!({
      key: ENV.fetch('GOOGLE_PLACES_API_KEY'),
      types: '(regions)',
      fields: 'geometry',
    })

    url = "https://maps.googleapis.com/maps/api/place/details/json?#{parameters.to_query}"
    response = HTTParty.get(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })

    if response['result'].present?
      geometry = response['result']['geometry']
      v = response['result']['geometry']['viewport']
      center = Geokit::LatLng.normalize(geometry['location']['lat'], geometry['location']['lng'])
      radius = [
        Geokit::LatLng.normalize(v['southwest']['lat'], v['northeast']['lng']).distance_to(center),
        Geokit::LatLng.normalize(v['northeast']['lat'], v['southwest']['lng']).distance_to(center),
        Geokit::LatLng.normalize(v['northeast']['lat'], v['southwest']['lng']).distance_to(center),
        Geokit::LatLng.normalize(v['southwest']['lat'], v['northeast']['lng']).distance_to(center),
      ].max

      {
        latitude: center.lat,
        longitude: center.lng,
        radius: radius,
      }
    else
      nil
    end
  end

end
