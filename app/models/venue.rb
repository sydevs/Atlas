class Venue < ApplicationRecord

  # Extensions
  include ActivityMonitorable
  include Location

  nilify_blanks
  searchable_columns %w[name street city region_code country_code post_code]

  # Associations
  # belongs_to :country, foreign_key: :country_code, primary_key: :country_code

  has_many :area_venues
  has_many :areas, through: :area_venues

  has_many :events, inverse_of: :venue
  # has_many :events, as: :location, dependent: :delete_all, class_name: "OfflineEvent"
  has_many :publicly_visible_events, -> { publicly_visible }, class_name: 'OfflineEvent'

  # Validations
  validates_presence_of :place_id, :street, :city, :country_code
  validates_length_of :region_code, maximum: 3

  # Scopes
  scope :publicly_visible, -> { has_public_events }
  scope :has_public_events, -> { joins(:publicly_visible_events).uniq }

  # Delegations
  delegate :all_managers, to: :parent

  # Callbacks
  before_save :set_areas
  before_validation :fetch_coordinates, if: :place_id_changed?

  # Methods

  def parent
    areas.first
  end

  def managed_by? manager, super_manager: nil
    manager.areas.each do |area|
      return true if area.contains?(self)
    end

    parent.managed_by?(manager)
  end

  def cache_key
    "#{super}-#{last_activity_on.strftime("%d%m%Y")}"
  end

  def fetch_geo_data!
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
  end

  private

    def set_areas
      return unless latitude_changed? || longitude_changed?

      radius = Area.maximum(:radius)
      areas = Area.select('id, name, radius, latitude, longitude').within(radius, origin: self)
      areas = areas.to_a.filter { |area| area.contains?(self) }
      self.areas = areas
    end

    def fetch_coordinates
      return unless place_id.present?

      result = GoogleMapsAPI.fetch_place({
        language: I18n.locale,
        placeid: place_id,
      })

      self.latitude = result[:latitude]
      self.longitude = result[:longitude]
    end

end
