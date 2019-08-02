class Venue < ApplicationRecord

  nilify_blanks
  has_many :events

  validates :street, presence: true
  validates :country_code, presence: true
  validates :latitude, :longitude, presence: true
  validates :contact_name, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def label
    name || street
  end

  # Check if coordinates have been defined
  def coordinates?
    latitude.present? && longitude.present?
  end

  def full_address
    [street, municipality, subnational, country].compact.join(', ')
  end

  def address
    {
      street: street,
      municipality: municipality,
      subnational: subnational,
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
