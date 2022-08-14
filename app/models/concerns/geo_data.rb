module GeoData

  extend ActiveSupport::Concern

  included do
    validates_presence_of :osm_id, :geojson, :bounds, :translations
  end

  def contains? location
    point = Geokit::LatLng.new(location.latitude, location.longitude)
    polygons.any? { |p| p.contains?(point) }
  end

  def contains_geojson? geojson
    geojson['coordinates'].all? do |coordinates|
      coordinates.all? do |point|
        point = Geokit::LatLng.new(point[1], point[0])
        polygons.any? { |p| p.contains?(point) }
      end
    end
  end

  def custom_geodata?
    osm_id.to_i == 0
  end

  def bounds_geojson
    return nil unless bounds.present?

    {
      type: 'Polygon',
      coordinates: [[
        [bounds[2].to_f, bounds[0].to_f],
        [bounds[3].to_f, bounds[0].to_f],
        [bounds[3].to_f, bounds[1].to_f],
        [bounds[2].to_f, bounds[1].to_f],
        [bounds[2].to_f, bounds[0].to_f],
      ]],
    }
  end

  def fetch_geo_data! data: nil
    return if osm_id.nil? || custom_geodata?

    data ||= OpenStreetMapsAPI.fetch_data(osm_id)
    self.assign_attributes({
      name: data[:display_name].split(',', 2).first,
      osm_id: osm_id, 
      geojson: data[:geojson],
      bounds: data[:boundingbox],
      country_code: data[:address][:country_code],
      translations: data[:namedetails].to_a.filter_map do |key, value|
        key = key.to_s.split(':')
        [key[1] || 'en', value] if key[0] == 'name'
      end.to_h,
    })
  end

  def self.parse_params params
    %i[bounds geojson translations].each do |key|
      params[key] = params[key].present? ? JSON.parse(params[key]) : nil
    end

    params[:osm_id] = params[:osm_id].to_f
    params
  end

  def polygons
    return [] unless geojson?

    @polygons ||= geojson['coordinates'].map do |coordinates|
      Geokit::Polygon.new(coordinates[0].map { |c| Geokit::LatLng.new(c[1], c[0]) })
    end
  end

end
