class Region < ApplicationRecord

  # Extensios
  include GeoData
  include Manageable
  include ActivityMonitorable

  searchable_columns %w[name country_code translations]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :areas, dependent: :delete_all

  has_many :venues, foreign_key: :province_code, primary_key: :province_code
  has_many :events, through: :venues
  # has_many :associated_registrations, through: :events, source: :registrations

  # Validations
  validates_presence_of :name, :country_code
  validate :validate_geojson

  # Scopes
  default_scope { order(name: :desc) }
  
  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", PlaceMailer::SUMMARY_PERIOD.ago) }

  # Delegations
  alias parent country

  # Methods

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if country.managed_by?(manager) && super_manager != false
  end

  def fetch_geo_data!
    return if osm_id.nil? || custom_geodata?

    data = OpenStreetMapsAPI.fetch_data(osm_id)

    if data[:address][:country_code] != country_code.downcase
      self.errors.add(:osm_id, I18n.translate('cms.messages.region.invalid_osm_id', country: CountryDecorator.get_label(country_code)))
    else
      super data: data
    end
  end

  private

    def validate_geojson
      return unless geojson.present?
      return if parent.contains_geojson?(geojson)

      errors.add(:geojson, I18n.translate('cms.messages.region.invalid_geojson', region: parent.name))
    end

end
