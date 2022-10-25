class Area < ApplicationRecord

  # Extensions
  include Manageable
  include ActivityMonitorable
  include HasClient
  include Location

  nilify_blanks
  searchable_columns %w[name]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code
  belongs_to :region, optional: true

  has_many :area_venues
  has_many :venues, through: :area_venues
  has_many :registrations, through: :events

  has_many :events, dependent: :delete_all
  has_many :publicly_visible_events, -> { publicly_visible }, class_name: 'Event'

  # Validations
  before_validation :set_country_code
  validates_presence_of :name, :radius, :country_code
  validate :validate_location

  # Scopes
  default_scope { order(name: :desc) }

  scope :publicly_visible, -> { has_public_events }
  scope :has_public_events, -> { joins(:publicly_visible_events).uniq }

  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", PlaceMailer::SUMMARY_PERIOD.ago) }

  # Callbacks
  after_save :set_venues

  # Methods

  def parent
    region || country || nil
  end

  def associated_registrations
    Registration.where(event_id: events)
  end

  def flexible_radius
    radius + 1 # Allow 1km extra
  end

  def contains? venue
    distance_to(venue) <= flexible_radius
  end

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if region.present? && region.managed_by?(manager) && super_manager != false
    return true if country.present? && country.managed_by?(manager) && super_manager != false

    false
  end

  def publicly_visible?
    true
  end

  def bounds
    [
      latitude - radius,
      latitude + radius,
      longitude - radius,
      longitude + radius,
    ]
  end

  def to_bounds flexible: false
    {
      latitude: latitude,
      longitude: longitude,
      radius: flexible ? flexible_radius : radius,
    }
  end

  def published?
    true
  end

  private

    def set_country_code
      self.country_code = region.country_code if region.present?
    end

    def set_venues
      return unless (previous_changes.keys && %w[radius latitude longitude]).present?

      self.venues = Venue.select('id, latitude, longitude').within(flexible_radius, origin: self)
      save!
    end

    def validate_location
      return unless latitude.present? && longitude.present?
      return if parent.contains?(self)

      errors.add(:coordinates, I18n.translate('cms.messages.area.invalid_location', region: parent.name, country: parent.parent.name))
    end

end
