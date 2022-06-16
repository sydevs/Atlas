class LocalArea < ApplicationRecord

  # Extensions
  include Manageable
  include ActivityMonitorable
  include Location

  nilify_blanks
  searchable_columns %w[name identifier province_code country_code]
  audited except: %i[summary_email_sent_at summary_metadata]

  # Associations
  belongs_to :country, foreign_key: :country_code, primary_key: :country_code, optional: true
  belongs_to :province, foreign_key: :province_code, primary_key: :province_code, optional: true

  has_many :local_area_venues
  has_many :venues, through: :local_area_venues
  # has_many :associated_registrations, through: :associated_events, source: :registrations

  has_many :events, as: :location, dependent: :delete_all, class_name: "OnlineEvent"
  has_many :abstract_events, as: :location, class_name: "Event"
  has_many :publicly_visible_events, -> { publicly_visible }, as: :location, class_name: 'OnlineEvent'

  # Validations
  before_validation :ensure_country_consistency
  validates_presence_of :radius, :name

  # Scopes
  default_scope { order(name: :desc) }

  scope :publicly_visible, -> { has_public_events }
  scope :has_public_events, -> { joins(:publicly_visible_events) }

  scope :cross_province, -> { where(province_code: nil) }
  scope :international, -> { cross_province.where(country_code: nil) }

  scope :ready_for_summary_email, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", RegionMailer::SUMMARY_PERIOD.ago) }

  # Callbacks
  after_save :ensure_venue_consistency

  # Methods

  def parent
    province || country || nil
  end

  def associated_events
    events_via_venues = Event.where(location_id: venues)
    abstract_events.or(events_via_venues)
  end

  def associated_registrations
    Registration.where(event_id: events)
  end

  def flexible_radius
    radius * 1.2
  end

  def contains? venue
    distance_to(venue) <= flexible_radius
  end

  def managed_by? manager, super_manager: nil
    return true if managers.include?(manager) && super_manager != true
    return true if province.present? && province.managed_by?(manager) && super_manager != false
    return true if country.present? && country.managed_by?(manager) && super_manager != false

    false
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

    def ensure_country_consistency
      self.country_code = province.country_code if province.present?
    end

    def ensure_venue_consistency
      return unless (previous_changes.keys & %w[radius latitude longitude province_code country_code]).present?

      venues = Venue.select('id, latitude, longitude').within(flexible_radius, origin: self)
      venues = venues.where(country_code: country_code) if country_code?
      venues = venues.where(province_code: province_code) if province_code?
      self.venues = venues
    end

end
