class Province < ApplicationRecord

  # Extensios
  include Manageable

  searchable_columns %w[province_code country_code]
  audited

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  has_many :local_areas, inverse_of: :province, foreign_key: :province_code, primary_key: :province_code, dependent: :delete_all

  has_many :venues, foreign_key: :province, primary_key: :province_code
  has_many :events, through: :venues

  # Validations
  validates_presence_of :province_code, :country_code

  # Scopes
  default_scope { order(province_code: :desc) }

  # Delegations
  alias parent country

  # Methods

  def contains? venue
    venue.province == province_code
  end

  def managed_by? manager, super_manager: false
    return true if managers.include?(manager) && !super_manager

    country.managed_by?(manager)
  end

end
