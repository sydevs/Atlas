class Regions::LocalArea < ApplicationRecord

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  nilify_blanks
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  belongs_to :province, foreign_key: :province_name, primary_key: :province_name

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

  def venues
    Venue.within(radius, origin: self)
  end

  def events
    Event.joins(:venue).within(radius, origin: self)
  end

end
