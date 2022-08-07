class Region < ApplicationRecord

  # Extensios
  include Manageable
  include ActivityMonitorable

  searchable_columns %w[province_code country_code]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :areas, dependent: :delete_all

  has_many :venues, foreign_key: :province_code, primary_key: :province_code
  has_many :events, through: :venues
  # has_many :associated_registrations, through: :events, source: :registrations

  # Validations
  validates_presence_of :name, :geojson, :country_code

  # Scopes
  default_scope { order(name: :desc) }
  
  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", PlaceMailer::SUMMARY_PERIOD.ago) }

  # Delegations
  alias parent country

  # Methods

  def contains? venue
    venue.region == province_code
  end

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if country.managed_by?(manager) && super_manager != false
  end

  def fetch_geo_data!
    return if osm_id.nil?

    data = OpenStreetMapsAPI.fetch_data(osm_id)

    if data[:address][:country_code] != country_code.downcase
      self.errors.add(:osm_id, "is not within #{CountryDecorator.get_label(country_code)}")
      return
    end

    self.assign_attributes({
      name: data[:display_name].split(',', 2).first,
      osm_id: osm_id, 
      geojson: data[:geojson],
      bounds: data[:boundingbox],
      translations: data[:namedetails].to_a.filter_map do |key, value|
        key = key.to_s.split(':')
        [key[1] || 'en', value] if key[0] == 'name'
      end.to_h,
    })
  end

end
