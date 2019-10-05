class Venue < ApplicationRecord

  include Manageable
  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude
  
  nilify_blanks
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code, optional: true
  belongs_to :province, foreign_key: :province_code, primary_key: :province_code, optional: true
  has_many :events

  validates :street, presence: true
  validates :country_code, presence: true
  validates :latitude, :longitude, presence: true

  searchable_columns %w[name street city province_code country_code]
  alias_method :parent, :province

  default_scope { order(updated_at: :desc) }

  def label
    name || street
  end

  def managed_by? manager, super_manager: false
    return true if !super_manager && managers.include?(manager)
    
    manager.local_areas.each do |local_area|
      return true if local_area.contains?(venue)
    end

    return parent.managed_by?(manager)
  end

  # Check if coordinates have been defined
  def coordinates?
    latitude.present? && longitude.present?
  end
  
  def full_address
    [street, city, province_code, country_code].compact.join(', ')
  end

  def address
    {
      street: street,
      city: city,
      province: province_code,
      country: country_code,
      postcode: postcode,
    }
  end

  def country
    I18nData.countries(I18n.locale)[country_code]
  end

  def country_code= value
    value = value.to_s.upcase
    # Only accept country codes which are in the language list
    super value if I18nData.countries.keys.include?(value)
  end

end
