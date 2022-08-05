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

  def bounds
    self[:bounds].split(',')
  end

  def default_language_code= value
    # Only accept languages which are in the language list
    super value if I18nData.languages.key?(value)
  end

end
