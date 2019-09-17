class Regions::Province < ApplicationRecord

  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :province, foreign_key: :province_name, primary_key: :province_name

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

  scope :venues, -> { Venue.where(province_name: province_name, country_code: country_code) }
  scope :events, -> { Event.includes(:venue).where(venues: { province_name: province_name, country_code: country_code }) }

end
