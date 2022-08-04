class OnlineEvent < Event
  # Associations
  belongs_to :local_area
  acts_as_mappable through: :local_area

  # Scopes
  default_scope { online }

  # Delegations
  delegate :latitude, :longitude, to: :local_area
  alias parent local_area
end
