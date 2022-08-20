class OnlineEvent < Event
  # Associations
  belongs_to :area
  acts_as_mappable through: :area

  # Scopes
  default_scope { online }

  # Delegations
  delegate :latitude, :longitude, to: :area
end
