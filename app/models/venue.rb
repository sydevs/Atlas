class Venue < ApplicationRecord

  include Manageable
  
  nilify_blanks
  has_many :events

  validates :street, presence: true
  validates :country_code, presence: true
  validates :latitude, :longitude, presence: true

  def label
    name || street
  end

  # Check if coordinates have been defined
  def coordinates?
    latitude.present? && longitude.present?
  end

  def full_address
    [street, city, province, country].compact.join(', ')
  end

  def address
    {
      street: street,
      city: city,
      province: province,
      country: country,
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
