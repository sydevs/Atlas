class OfflineEvent < Event
  # Associations
  belongs_to :venue, inverse_of: :events
  acts_as_mappable through: :venue

  # Scopes
  default_scope { offline }
  scope :with_location, -> (country_code) { joins(:venue).where_country(country_code) }
  scope :where_country, -> (country_code) { where(venues: { country_code: country_code }) if country_code }

  # Delegations
  alias location venue
  delegate :latitude, :longitude, to: :venue
end
