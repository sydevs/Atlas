class Venue < ApplicationRecord

  # Extensions
  include Publishable
  include ActivityMonitorable
  include Location

  audited
  nilify_blanks
  searchable_columns %w[name street city province_code country_code]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code, optional: true
  belongs_to :region, foreign_key: :province_code, primary_key: :province_code, optional: true

  has_many :area_venues
  has_many :areas, through: :area_venues

  has_many :events, inverse_of: :venue
  # has_many :events, as: :location, dependent: :delete_all, class_name: "OfflineEvent"
  has_many :publicly_visible_events, -> { publicly_visible }, class_name: 'OfflineEvent'

  # Validations
  # validates :street, presence: true
  # validates :province_code, presence: true, if: :country_has_regions?
  # validates :country_code, presence: true
  validates_presence_of :place_id, :address

  # Scopes
  scope :has_public_events, -> { joins(:publicly_visible_events) }
  scope :publicly_visible, -> { published.has_public_events }

  # Delegations
  delegate :all_managers, to: :parent

  # Callbacks
  after_save :ensure_area_consistency
  after_save :update_activity_timestamps
  before_create :fetch_coordinates

  # Methods

  def parent
    areas.first || (country.enable_regions? ? region || country : country)
  end

=begin
  def street
    address&.split(',', 2)&.first# || self[:street]
  end
=end

  def managed_by? manager, super_manager: nil
    manager.areas.each do |area|
      return true if area.contains?(self)
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

  def cache_key
    "#{super}-#{last_activity_on.strftime("%d%m%Y")}"
  end

  private

    def ensure_area_consistency
      return unless (previous_changes.keys & %w[latitude longitude province_code country_code]).present?

      radius = Area.maximum(:radius)
      areas = Area.select('id, name, radius, latitude, longitude, country_code, province_code').within(radius, origin: self)
      areas = areas.where(country_code: country_code) if country_code?
      areas = areas.where(province_code: province_code) if province_code?
      areas = areas.to_a.filter { |area| area.contains?(self) }
      self.areas = areas
    end

    def country_has_regions?
      return country.nil? || country.enable_regions
    end

    def fetch_coordinates
      result = GoogleMapsAPI.fetch_place({
        language: I18n.locale,
        placeid: place_id,
      })

      self.latitude = result[:latitude]
      self.longitude = result[:longitude]
    end

end
