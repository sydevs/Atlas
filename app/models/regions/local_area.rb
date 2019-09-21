class Regions::LocalArea < ApplicationRecord

  before_validation :ensure_country_consistency

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  nilify_blanks
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code, optional: true
  belongs_to :province, foreign_key: :province_name, primary_key: :province_name, optional: true

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

  validates_presence_of :latitude, :longitude, :radius, :name, :identifier

  def venues
    scope = Venue.within(radius, origin: self)
    scope = scope.where(country_code: country_code) if country_code?
    scope = scope.where(province: province_name) if province_name?
    scope
  end

  def events
    scope = Event.joins(:venue).within(radius, origin: self)
    scope = scope.where(venues: { country_code: country_code }) if country_code?
    scope = scope.where(venues: { province: province_name }) if province_name?
    scope
  end

  def contains? venue
    distance_to(venue) <= radius
  end

  def managed_by? manager, super_manager: false
    return true if managers.include?(manager) && !super_manager
    return true if province.present? && province.managed_by?(manager)
    return true if country.present? && country.managed_by?(manager)
    return false
  end

  private

    def ensure_country_consistency
      self[:country_code] = province.country_code if province.present?
    end

end
