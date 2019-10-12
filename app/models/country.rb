class Country < ApplicationRecord

  # Extensions
  include Manageable
  searchable_columns %w[country_code]

  # Associations
  has_many :provinces, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all
  has_many :local_areas, inverse_of: :country, foreign_key: :country_code, primary_key: :country_code, dependent: :delete_all

  has_many :venues, foreign_key: :country_code, primary_key: :country_code
  has_many :events, through: :venues

  # Validations
  validates_presence_of :country_code

  # Scopes
  default_scope { order(country_code: :desc) }

  # Methods
  
  def contains? venue
    venue.country_code == country_code
  end

  def managed_by? manager, super_manager: false
    return managers.include?(manager) unless super_manager
    return false
  end

end
