class OnlineEvent < Event
  # Associations
  belongs_to :local_area, foreign_key: :location_id
  acts_as_mappable through: :local_area

  # Validations
  validates :location_type, presence: true, inclusion: { in: ['LocalArea'] }
  validates :online_url, presence: true

  # Delegations
  alias parent local_area

  # Callbacks
  before_save -> { self[:location_type] = 'LocalArea' }
end
