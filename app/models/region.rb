class Region < ApplicationRecord

  # Extensios
  include GeoData
  include Manageable
  include HasClient
  include ActivityMonitorable

  nilify_blanks
  searchable_columns %w[name country_code translations]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :areas, dependent: :delete_all

  has_many :events, through: :areas
  has_many :publicly_visible_events, -> { publicly_visible }, through: :areas, class_name: 'Event'

  has_many :venues, through: :events
  has_many :registrations, through: :events

  # Validations
  validates_presence_of :name
  validate :validate_geojson

  # Scopes
  # default_scope { order(name: :desc) }
  
  scope :publicly_visible, -> { has_public_events }
  scope :has_public_events, -> { joins(:publicly_visible_events).uniq }
  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", PlaceMailer::SUMMARY_PERIOD.ago) }

  # Delegations
  alias parent country

  # Methods

  def contains? location
    super && parent.contains?(location)
  end

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if country.managed_by?(manager) && super_manager != false
  end

  def publicly_visible?
    true
  end

  def fetch_geo_data!
    return if osm_id.nil? || custom_geodata?

    data = OpenStreetMapsAPI.fetch_data(osm_id, precision: 0.06)
    if data[:address][:country_code] != country_code.downcase
      self.errors.add(:osm_id, I18n.translate('cms.messages.region.invalid_osm_id', country: CountryDecorator.get_label(country_code)))
    else
      super data: data
    end
  rescue OpenStreetMapsAPI::ResponseError => e
    errors.add(:osm_id, ': ' + e.message)
  end

  private

    def validate_geojson
      return unless geojson.present?
      return if parent.contains_geojson?(self)

      errors.add(:geojson, I18n.translate('cms.messages.region.invalid_geojson', country: parent.name))
    end

end
