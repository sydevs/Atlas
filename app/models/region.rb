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
  validates_presence_of :name, :osm_id, :geojson, :country_code

  # Scopes
  default_scope { order(name: :desc) }
  
  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", PlaceMailer::SUMMARY_PERIOD.ago) }

  # Delegations
  alias parent country

  # Callbacks
  before_validation :fetch_geojson

  # Methods

  def contains? venue
    venue.region == province_code
  end

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if country.managed_by?(manager) && super_manager != false
  end

  private

    def fetch_geojson
      return unless osm_id_changed? || geojson.nil?

      self.geojson = OpenStreetMapsAPI.fetch_data(osm_id)
    end

end
