module Location

  extend ActiveSupport::Concern

  included do
    acts_as_mappable default_units: :kms, lat_column_name: :latitude, lng_column_name: :longitude
    validates_presence_of :latitude, :longitude, :time_zone
    before_validation :fetch_time_zone
  end

  def coordinates?
    latitude.present? && longitude.present?
  end

  def coordinates
    [latitude, longitude]
  end

  private

    def fetch_time_zone
      return unless latitude_changed? || longitude_changed? || time_zone.nil?
      return unless coordinates?

      self.time_zone = Timezone.lookup(latitude, longitude)
    end

end
