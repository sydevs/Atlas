class OfflineEvent < Event
  # Associations
  belongs_to :venue, foreign_key: :location_id
  acts_as_mappable through: :venue

  # Validations
  validates :location_type, presence: true, inclusion: { in: ['Venue'] }

  # Delegations
  alias parent venue

  # Callbacks
  before_save -> { self[:location_type] = 'Venue' }

  # Methods

  def parent_managers
    venue.parent.managers
  end
end
