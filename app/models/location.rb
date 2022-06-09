class Location < ApplicationRecord
  self.abstract_class = true

  # Extensions
  acts_as_mappable default_units: :kms, lat_column_name: :latitude, lng_column_name: :longitude

  # Associations
  has_many :events, dependent: :delete_all
  has_many :publicly_visible_events, -> { publicly_visible }, class_name: 'Event'

  # Scopes
  scope :has_public_events, -> { joins(:publicly_visible_events) }

  def time_zone
    Timezone.lookup(latitude, longitude)
  end

end
