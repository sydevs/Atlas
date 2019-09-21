class Province < ApplicationRecord

  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :province, foreign_key: :province_name, primary_key: :province_name, dependent: :delete_all

  has_many :managed_regions, as: :region
  has_many :managers, through: :managed_regions

  has_many :venues, foreign_key: :province, primary_key: :province_name
  has_many :events, through: :venues
  searchable_columns %w[province_name country_code]
  alias_method :parent, :country

  validates_presence_of :province_name, :country_code

  def label
    "#{province_name}, #{country_code}"
  end

  def contains? venue
    venue.province == province_name
  end

  def managed_by? manager, super_manager: false
    return true if managers.include?(manager) && !super_manager
    return country.managed_by?(manager)
  end

end
