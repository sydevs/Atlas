require 'httparty'

## AUTOCOMPLETE
# This concern simplifies requests to geocode addresses

module OpenStreetMapsAPI

  def self.fetch_geojson osm_id
    url = "http://polygons.openstreetmap.fr/get_geojson.py?id=#{osm_id}&params=0.090000-0.090000-0.090000"
    response = HTTParty.get(url, { headers: { 'Content-Type': 'application/json' }, log_level: :debug })
    puts "#{url} - #{response.pretty_inspect}"

    JSON.parse(response.body)
  end

  def self.fetch_data osm_id
    url = "http://polygons.openstreetmap.fr/get_geojson.py?id=#{osm_id}&params=0.090000-0.090000-0.090000"
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
    puts "#{url} - #{response.pretty_inspect}"

    data = JSON.parse(response.body)
    data[0]['geojson']
  end

end
