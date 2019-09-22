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
    I18nData.countries(I18n.locale)[country_code]
  end

  def self.get_label country_code
    I18nData.countries(I18n.locale)[country_code]
  end

  def contains? venue
    venue.country_code == country_code
  end

  def managed_by? manager, super_manager: false
    return managers.include?(manager) unless super_manager
    return false
  end

end
