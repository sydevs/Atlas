class LocalArea < ApplicationRecord

  # Extensions
  include Manageable

  nilify_blanks
  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude
  searchable_columns %w[name identifier province_code country_code]
  audited

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code, optional: true
  belongs_to :province, foreign_key: :province_code, primary_key: :province_code, optional: true

  # Validations
  before_validation :ensure_country_consistency
  validates_presence_of :latitude, :longitude, :radius, :name

  # Scopes
  default_scope { order(name: :desc) }
  scope :cross_province, -> { where(province_code: nil) }
  scope :international, -> { cross_province.where(country_code: nil) }

  # Methods

  def parent
    province || country || nil
  end

  def venues
    scope = Venue.within(radius, origin: self)
    scope = scope.where(country_code: country_code) if country_code?
    scope = scope.where(province: province_code) if province_code?
    scope
  end

  def events
    scope = Event.joins(:venue).within(radius, origin: self)
    scope = scope.where(venues: { country_code: country_code }) if country_code?
    scope = scope.where(venues: { province: province_code }) if province_code?
    scope
  end

  def contains? venue
    distance_to(venue) <= radius
  end

  def managed_by? manager, super_manager: false
    return true if managers.include?(manager) && !super_manager
    return true if province.present? && province.managed_by?(manager)
    return true if country.present? && country.managed_by?(manager)

    false
  end

  private

    def ensure_country_consistency
      self.country_code = province.country_code if province.present?
    end

end
