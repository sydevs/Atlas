class Regions::LocalArea < ApplicationRecord

  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  belongs_to :province, foreign_key: :province_name, primary_key: :province_name

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

end
