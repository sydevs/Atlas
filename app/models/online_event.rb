class OnlineEvent < Event
  # Associations
  belongs_to :area
  acts_as_mappable through: :area

  # Scopes
  default_scope { online }
  scope :with_location, -> (country_code) { joins(:area).where_country(country_code) }
  scope :where_country, -> (country_code) { where(areas: { country_code: country_code }) if country_code }

  # Delegations
  alias location area
  delegate :latitude, :longitude, to: :area
end
