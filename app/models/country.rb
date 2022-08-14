class Country < ApplicationRecord

  # Extensions
  include Manageable
  include ActivityMonitorable

  searchable_columns %w[country_code]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  has_many :regions, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all
  has_many :areas, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all

  has_many :venues, foreign_key: :country_code, primary_key: :country_code
  has_many :events, through: :venues
  has_many :associated_registrations, through: :events, source: :registrations
  has_many :region_manager_records, through: :regions, source: :managed_records
  has_many :area_manager_records, through: :areas, source: :managed_records

  # Validations
  validates_presence_of :country_code
  validate :validate_language_code

  # Scopes
  default_scope { order(country_code: :desc) }

  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", CountryMailer::SUMMARY_PERIOD.ago) }

  # Methods

  def contains? venue
    venue.country_code == country_code
  end

  def managed_by? manager, super_manager: nil
    return managers.include?(manager) unless super_manager == true

    false
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

  def fetch_geo_data!
    return if osm_id.nil?

    data = OpenStreetMapsAPI.fetch_data(osm_id)
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

  private

    def validate_language_code
      return if I18nData.languages.key?(default_language_code)

      self.errors.add(:default_language_code)
    end

end
