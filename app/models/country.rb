class Country < ApplicationRecord

  include Manageable

  has_many :provinces, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all
  has_many :local_areas, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all

  has_many :venues, foreign_key: :country_code, primary_key: :country_code
  has_many :events, through: :venues

  validates_presence_of :country_code
  searchable_columns %w[country_code]

  default_scope { order(country_code: :desc) }

  def label
    ISO3166::Country[country_code].name
  end

  def self.get_label country_code
    ISO3166::Country[country_code].name
  end

  def contains? venue
    venue.country_code == country_code
  end

  def managed_by? manager, super_manager: false
    return managers.include?(manager) unless super_manager
    return false
  end

  def to_s
    label
  end

end
