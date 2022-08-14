require 'httparty'

## AUTOCOMPLETE
# This concern simplifies requests to geocode addresses

module OpenStreetMapsAPI

  def self.fetch_data osm_id
    cache_key = "osm-#{osm_id}"
    data = Rails.cache.read(cache_key)
    return data if data
    
    response = HTTParty.get('https://nominatim.openstreetmap.org/lookup', {
      headers: { 'Content-Type': 'application/json' },
      query: {
        format: 'json',
        osm_ids: "R#{osm_id}",
        namedetails: 1,
        polygon_geojson: 1,
        polygon_threshold: 0.06,
        email: 'contact@sydevelopers.com',
        'accept-language': I18n.locale.to_s,
      },
      log_level: :debug
    })

    # TODO: Implement error handling
    data = JSON.parse(response.body)
    data = data[0].deep_symbolize_keys

    Rails.cache.write(cache_key, data, expires_in: 1.day)
    data
  end

end
