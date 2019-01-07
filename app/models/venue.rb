class Venue < ApplicationRecord
  nilify_blanks
  has_many :events

  validates :address_street, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def label
    name || address_street
  end

  # Check if coordinates have been defined
  def has_coordinates?
    latitude.present? and longitude.present?
  end

  def address format = nil
    if format == :full
      [address_street, address_municipality, address_subnational, address_country].compact.join(', ')
    else
      {
        room: address_room,
        street: address_street,
        municipality: address_municipality,
        subnational: address_subnational,
        country: address_country,
        postcode: address_postcode,
      }
    end
  end

end
