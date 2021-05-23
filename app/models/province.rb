class Province < ApplicationRecord

  # Extensios
  include Manageable
  include ActivityMonitorable

  searchable_columns %w[province_code country_code]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :province, foreign_key: :province_code, primary_key: :province_code, dependent: :delete_all

  has_many :venues, foreign_key: :province, primary_key: :province_code
  has_many :events, through: :venues
  # has_many :associated_registrations, through: :events, source: :registrations

  # Validations
  validates_presence_of :province_code, :country_code

  # Scopes
  default_scope { order(province_code: :desc) }
  
  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", RegionMailer::SUMMARY_PERIOD.ago) }

  # Delegations
  alias parent country

  # Methods

  def contains? venue
    venue.province == province_code
  end

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if country.managed_by?(manager) && super_manager != false
  end

end
