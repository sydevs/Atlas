class Event < ApplicationRecord

  # Extensions
  include Publishable
  include AASM # State machine - required for Expirable
  include Expirable
  include Recurrable
  include ActivityMonitorable
  include Managed
  include Audited

  nilify_blanks
  searchable_columns %w[custom_name description]

  enum category: { dropin: 1, course: 3, single: 2, festival: 4, concert: 5, inactive: 6 }, _suffix: true
  enum registration_mode: { native: 0, external: 1, meetup: 2, eventbrite: 3, facebook: 4 }, _suffix: true
  enum registration_notification: { digest: 0, immediate: 1, disabled: 2 }, _suffix: true
  flag :registration_question, %i[questions experience aspirations referral]

  # Associations
  belongs_to :area
  belongs_to :venue, optional: true, inverse_of: :events

  has_many :registrations, dependent: :delete_all
  has_many :pictures, as: :parent, dependent: :destroy

  accepts_nested_attributes_for :pictures, :venue

  # Validations
  validates_presence_of :type, :category, :language_code, :manager
  validates_presence_of :recurrence_type, :recurrence_start_date, :recurrence_start_time, unless: :inactive_category?
  validates_presence_of :recurrence_end_date, if: :course_category?
  validates_presence_of :recurrence_end_time, if: -> { festival_category? || concert_category? }
  validates_presence_of :online_url, if: :online?
  validates_presence_of :venue, unless: :online?
  validates_length_of :custom_name, maximum: 255
  validates_length_of :description, minimum: 40, maximum: 600, allow_blank: true
  validates :registration_url, url: true, unless: :native_registration_mode?
  validates :phone_number, phone: { possible: true, allow_blank: true, country_specifier: -> event { event.country_code } }
  validates_numericality_of :registration_limit, greater_than: 0, allow_nil: true
  validates_associated :pictures
  validate :validate_language_code
  validate :validate_location
  validate :parse_phone_number

  # Scopes
  scope :with_new_registrations, -> { where('events.latest_registration_at >= events.summary_email_sent_at') }
  scope :current, -> { where('events.finish_date IS NULL OR events.finish_date >= ?', DateTime.now) }
  scope :publicly_visible, -> { current.manager_verified.publishable.published }
  scope :manager_verified, -> { joins(:manager).where('managers.email_verified = TRUE OR managers.phone_verified = TRUE') }
  scope :with_location, -> (country_code) { joins(:area).where_country(country_code) }
  scope :where_country, -> (country_code) { where(areas: { country_code: country_code }) if country_code }
  scope :ready_for_registrations_email, -> do
    where(registration_notification: Event.registration_notifications[:immediate])
      .or(
        where(registration_notification: Event.registration_notifications[:digest])
        .where("registrations_email_sent_at IS NULL OR registrations_email_sent_at <= ?", 18.hours.ago)
      )
  end

  scope :layer, -> (layer) { layer == 'online' ? online : offline }
  scope :online, -> (online=true) { online ? where(type: 'OnlineEvent') : offline }
  scope :offline, -> { where(type: 'OfflineEvent') }

  # Delegations
  delegate :time_zone, :country_code, :canonical_domain, :nearest_parent_managers, :nearest_parent_manager, to: :area
  alias default_message_receiver nearest_parent_manager
  alias associated_registrations registrations
  alias parent area

  # Callbacks
  before_validation -> { self.description = description&.encode(description.encoding, universal_newline: true) || "" }
  before_validation :find_venue, unless: :online?
  after_create :verify_manager
  before_save :set_finish_date

  # Methods

  def layer
    online? ? 'online' : 'offline'
  end

  def location
    online? ? area : venue
  end

  def online?
    type == 'OnlineEvent'
  end

  def publicly_visible?
    manager.verified? && published? && publishable?
  end

  def should_finish?
    next_recurrence_at.nil? && !inactive_category?
  end

  def registration_end_time
    @registration_end_time ||= begin
      if %i[course single concert].include?(category)
        recurrence.starts_at
      elsif recurrence.finite?
        start_time = recurrence.starts_at.to_s(:time)
        time = start_time.split(":").map(&:to_i)
        recurrence.ends_at.change(hour: time[0], minute: time[1])
      end
    end
  end

  def label
    custom_name || venue&.street || area&.name || "Event ##{id}"
  end

  def language_code
    self[:language_code]&.downcase&.to_sym
  end

  def log_status_change
    return if archived? || new_record? || !published?
    
    EventMailer.with(event: self, manager: manager).status.deliver_later

    if needs_urgent_review?
      nearest_parent_managers.each do |parent_manager|
        EventMailer.with(event: self, manager: parent_manager).status.deliver_later
      end
    end
  end

  def cache_key
    "#{super}-#{status}-#{last_activity_on.strftime("%d%m%Y")}"
  end

  def manager_verified?
    manager.email_verified?
  end

  def default_language_code
    (language_code || area.country.default_language_code || I18n.locale).to_s.upcase
  end

  def parent_managers
    parent.managers
  end

  def expiration_base
    expiration_period.months + expiration_bonus
  end

  def expiration_bonus
    (expiration_period / 3 * [4, verification_streak].min).weeks
  end

  def conversation_members
    [manager] + parent_managers
  end

  def self.model_name
    ActiveModel::Name.new(base_class)
  end

  private

    def validate_location
      return unless venue.present? && venue.latitude.present? && venue.longitude.present?
      return if area.contains?(venue)

      self.errors.add(:venue, I18n.translate('cms.messages.venue.invalid_location', area: area.name))
    end

    def validate_language_code
      self[:language_code] = self[:language_code]&.upcase
      return if I18nData.languages.key?(self[:language_code])

      self.errors.add(:language_code)
    end

    def parse_phone_number
      self.phone_number = Phonelib.parse(phone_number, country_code).international
    end

    def verify_manager
      return if manager.email_verified?

      ManagerMailer.with(manager: manager, context: self).verify.deliver_later
      manager.touch(:email_verification_sent_at)
    end

    def set_finish_date
      self.finish_date = last_recurrence_at
    end

    def find_venue
      return unless venue_id.nil? || venue.place_id_changed?

      self.venue_id = Venue.find_by_place_id(venue.place_id)&.id
    end

end
