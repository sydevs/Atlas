module GeoData

  extend ActiveSupport::Concern

  included do
    validates_presence_of :osm_id, :geojson, :bounds, :country_code
    validates_presence_of :translations, unless: :custom_geodata?
    before_validation -> { country_code.upcase! }
    validates :osm_id, format: { with: /custom|[RN][0-9]+/ }
  end

  def contains? location
    point = Geokit::LatLng.new(location.latitude, location.longitude)
    polygons.any? { |p| p.contains?(point) }
  end

  def contains_geojson? record, strict: false
    if strict
      record.geojson['coordinates'].all? do |coordinates|
        coordinates.all? do |point|
          point = Geokit::LatLng.new(point[1], point[0])
          polygons.any? { |p| p.contains?(point) }
        end
      end
    else
      record.polygons.all? do |p|
        polygons.any? { |polygon| polygon.contains?(p.centroid) }
      end
    end
  end

  def custom_geodata?
    osm_id == 'custom'
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
      country_code: data[:address][:country_code].upcase,
      translations: data[:namedetails].to_a.filter_map do |key, value|
        key = key.to_s.split(':')
        [key[1] || 'en', value] if key[0] == 'name'
      end.to_h,
    })
  rescue OpenStreetMapsAPI::ResponseError => e
    errors.add(:osm_id, ': ' + e.message)
  end

  def self.parse_params params
    %i[bounds geojson translations].each do |key|
      params[key] = params[key].present? ? JSON.parse(params[key]) : nil
    end

    params
  end

  def polygons
    return [] unless geojson?

    @polygons ||= geojson['coordinates'].map do |coordinates|
      coordinates = coordinates[0] if coordinates[0].length > 2
      Geokit::Polygon.new(coordinates.map { |c| Geokit::LatLng.new(c[1], c[0]) })
    end
  end

end
