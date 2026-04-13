require 'httparty'

## AUTOCOMPLETE
# This concern simplifies requests to geocode addresses

module OpenStreetMapsAPI

  class ResponseError < StandardError
  end

  def self.fetch_data osm_id, precision: 0.06
    cache_key = "osm-#{osm_id}"
    data = Rails.cache.read(cache_key)
    return data if data
    
    response = HTTParty.get('https://nominatim.openstreetmap.org/lookup', {
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Atlas/1.0 (contact@sydevelopers.com)',
      },
      query: {
        format: 'json',
        osm_ids: osm_id,
        namedetails: 1,
        polygon_geojson: 1,
        polygon_threshold: precision,
        email: 'contact@sydevelopers.com',
        'accept-language': I18n.locale.to_s,
      },
      log_level: :debug
    })

    unless response.success?
      raise OpenStreetMapsAPI::ResponseError, "API request failed: #{response.body.truncate(100)}"
    end

    begin
      data = JSON.parse(response.body)
    rescue JSON::ParserError
      raise OpenStreetMapsAPI::ResponseError, "Invalid response from geocoding service"
    end
    data = data.first&.deep_symbolize_keys
    raise OpenStreetMapsAPI::ResponseError, "No Data Retrieved" unless data.present?

    Rails.cache.write(cache_key, data, expires_in: 1.day)
    data
  end

end
