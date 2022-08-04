class OfflineEvent < Event
  # Associations
  belongs_to :venue, inverse_of: :events
  acts_as_mappable through: :venue

  # Scopes
  default_scope { offline }

  # Delegations
  delegate :latitude, :longitude, to: :venue
  alias parent venue

  # Methods

  def parent_managers
    venue.parent.managers
  end
end
