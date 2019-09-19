class Regions::Province < ApplicationRecord

  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :province, foreign_key: :province_name, primary_key: :province_name

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

  has_many :venues, foreign_key: :province, primary_key: :province_name
  has_many :events, through: :venues

  validates_presence_of :province_name, :country_code

  def name
    "#{province_name}, #{country_code}"
  end

end
