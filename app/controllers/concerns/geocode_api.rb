require 'httparty'

## GEOCODE
# This concern simplifies requests to geocode addresses

module GeocodeAPI

  def self.googlemaps parameters
    parameters.merge!({
      key: ENV.fetch('GOOGLE_PLACES_API_KEY'),
      inputtype: 'textquery',
      fields: 'place_id,geometry',
    })

    url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?#{parameters.to_query}"
    response = HTTParty.get(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })

    if response['candidates'].length > 0
      candidate = response['candidates'][0]
      
      {
        latitude: candidate['geometry']['location']['lat'],
        longitude: candidate['geometry']['location']['lng'],
        place_id: candidate['place_id'],
      }
    else
      nil
    end
  end

end
