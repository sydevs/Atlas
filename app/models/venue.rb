class Venue < ApplicationRecord

  # Extensions
  include Publishable
  include ActivityMonitorable

  audited
  nilify_blanks
  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude
  searchable_columns %w[name street city province_code country_code]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code, optional: true
  belongs_to :province, foreign_key: :province_code, primary_key: :province_code, optional: true
  has_many :local_area_venues
  has_many :local_areas, through: :local_area_venues
  has_many :events, dependent: :delete_all

  # Validations
  validates :street, presence: true
  validates :province_code, presence: true, if: :country_has_provinces?
  validates :country_code, presence: true
  validates :latitude, :longitude, :time_zone, presence: true

  # Scopes
  scope :publicly_visible, -> { published.has_events }
  scope :has_events, -> { joins(:events).where.not(events: { status: Event.statuses.values_at(*%w[expired archived finished]) }) }
  scope :has_offline_events, -> { has_events.where(events: { online: false }) }
  scope :has_online_events, -> { has_events.where(events: { online: true }) }

  # Delegations
  delegate :all_managers, to: :parent

  # Callbacks
  before_validation :fetch_time_zone
  after_save :ensure_local_area_consistency
  after_save :update_activity_timestamps

  # Methods

  def parent
    local_areas.first || (country.enable_province_management? ? province || country : country)
  end

  def managed_by? manager, super_manager: nil
    manager.local_areas.each do |local_area|
      return true if local_area.contains?(self)
    end

    parent.managed_by?(manager)
  end

  # Check if coordinates have been defined
  def coordinates?
    latitude.present? && longitude.present?
  end

  def coordinates
    [latitude, longitude]
  end

  def country_code= value
    value = value.to_s.upcase
    # Only accept country codes which are in the language list
    super value if I18nData.countries.keys.include?(value)
  end

  private

    def fetch_time_zone
      return unless latitude_changed? || longitude_changed? || time_zone.nil?

      self.time_zone = Timezone.lookup(latitude, longitude)
    end

    def ensure_local_area_consistency
      return unless (previous_changes.keys & %w[latitude longitude province_code country_code]).present?

      radius = LocalArea.maximum(:radius)
      local_areas = LocalArea.select('id, name, radius, latitude, longitude').within(radius, origin: self)
      local_areas = local_areas.where(country_code: country_code) if country_code?
      local_areas = local_areas.where(province: province_code) if province_code?
      local_areas = local_areas.to_a.filter { |area| area.contains?(self) }
      self.local_areas = local_areas
    end

    def country_has_provinces?
      return country.nil? || country.enable_province_management
    end

end
