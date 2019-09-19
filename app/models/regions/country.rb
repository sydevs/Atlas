class Regions::Country < ApplicationRecord

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

  has_many :provinces, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code

  has_many :venues, foreign_key: :country_code, primary_key: :country_code
  has_many :events, through: :venues

  validates_presence_of :country_code

  def name
    I18nData.countries(I18n.locale)[country_code]
  end

  def self.get_name country_code
    I18nData.countries(I18n.locale)[country_code]
  end

  def unrestricted_local_areas
    @unrestricted_local_areas ||= local_areas.where(province_name: nil)
  end

end
