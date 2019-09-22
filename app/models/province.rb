class Province < ApplicationRecord

  include Manageable

  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :province, foreign_key: :province_code, primary_key: :province_code, dependent: :delete_all

  has_many :venues, foreign_key: :province, primary_key: :province_code
  has_many :events, through: :venues
  
  searchable_columns %w[province_code country_code]
  alias_method :parent, :country

  default_scope { order(province_code: :desc) }

  validates_presence_of :province_code, :country_code

  def name
    ISO3166::Country[country_code].subdivisions[province_code]['name']
  end

  def label
    "#{name}, #{country_code}"
  end

  def self.get_label province_code, country_code
    "#{ISO3166::Country[country_code].subdivisions[province_code]['name']}, #{country_code}"
  end

  def contains? venue
    venue.province == province_code
  end

  def managed_by? manager, super_manager: false
    return true if managers.include?(manager) && !super_manager
    return country.managed_by?(manager)
  end

  def to_s
    label
  end

end
