class Country < ApplicationRecord

  # Extensions
  include GeoData
  include Manageable
  include HasClient
  include ActivityMonitorable

  nilify_blanks
  searchable_columns %w[name country_code translations]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  has_many :regions, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all
  has_many :areas, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all

  has_many :events, through: :areas
  has_many :publicly_visible_events, -> { publicly_visible }, through: :areas, class_name: 'Event'

  has_many :associated_registrations, through: :events, source: :registrations
  has_many :region_manager_records, through: :regions, source: :managed_records
  has_many :area_manager_records, through: :areas, source: :managed_records

  # Validations
  validates_presence_of :name
  validate :validate_language_code

  # Scopes
  default_scope { order(name: :asc) }

  scope :publicly_visible, -> { has_public_events }
  scope :has_public_events, -> { joins(:publicly_visible_events).uniq }
  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", CountryMailer::SUMMARY_PERIOD.ago) }
  scope :order_by_registrations, -> { left_joins(:associated_registrations).group(:id).order('COUNT(registrations.id) DESC') }

  # Methods

  def managed_by? manager, super_manager: nil
    return managers.include?(manager) unless super_manager == true

    false
  end

  def publicly_visible?
    true
  end

  private

    def validate_language_code
      return unless default_language_code.present?
      return if I18nData.languages.key?(default_language_code)

      self.errors.add(:default_language_code)
    end

end
