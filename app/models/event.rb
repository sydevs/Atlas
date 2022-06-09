class Event < ApplicationRecord

  # Extensions
  include Publishable
  include AASM # State machine - required for Expirable
  include Expirable
  include ActivityMonitorable
  include Managed

  nilify_blanks
  searchable_columns %w[custom_name description]
  audited except: %i[
    summary_email_sent_at status_email_sent_at latest_registration_at
    should_update_status_at verified_at expired_at archived_at finished_at
    status
  ]

  enum category: { dropin: 1, course: 3, single: 2, festival: 4, concert: 5 }, _suffix: true
  enum recurrence: { day: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }
  enum registration_mode: { native: 0, external: 1, meetup: 2, eventbrite: 3, facebook: 4 }, _suffix: true

  # Associations
  belongs_to :location, polymorphic: true

  has_many :registrations, dependent: :delete_all
  has_many :pictures, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :pictures
  accepts_nested_attributes_for :manager

  # Validations
  validates :custom_name, length: { maximum: 255 }
  validates :category, :language_code, presence: true
  validates :recurrence, :start_date, :start_time, presence: true
  validates :description, length: { minimum: 40, maximum: 600, allow_blank: true }
  validates :registration_url, url: true, unless: :native_registration_mode?
  validates :phone_number, phone: { possible: true, allow_blank: true, country_specifier: -> event { event.venue.country_code } }
  validates :end_date, presence: true, if: :course_category?
  validates :end_time, presence: true, if: -> { festival_category? || concert_category? }
  validates :manager, presence: true
  validates_numericality_of :registration_limit, greater_than: 0, allow_nil: true
  validates_associated :pictures
  validate :validate_end_time
  validate :validate_end_date
  validate :parse_phone_number

  # Scopes
  scope :with_new_registrations, -> { where('events.latest_registration_at >= events.summary_email_sent_at') }
  scope :current, -> { where('events.end_date IS NULL OR events.end_date >= ?', DateTime.now) }
  scope :publicly_visible, -> { current.manager_verified.publishable.published }
  scope :manager_verified, -> { joins(:manager).where('managers.email_verified = TRUE OR managers.phone_verified = TRUE') }

  scope :ready_for_reminder_email, -> { where("reminder_email_sent_at IS NULL OR reminder_email_sent_at <= ?", 12.hours.ago) }

  scope :online, -> { where(type: 'OnlineEvent') }
  scope :offline, -> { where(type: 'OfflineEvent') }

  # Delegations
  alias associated_registrations registrations
  delegate :latitude, :longitude, to: :parent

  # Methods
  after_save :verify_manager

  def region_association?
    false
  end

  def publicly_visible?
    manager.verified? && published? && publishable?
  end

  def language_code= value
    # Only accept languages which are in the language list
    super value if I18nData.languages.key?(value)
  end

  def online?
    type == "OnlineEvent"
  end

  def should_finish?
    next_occurrence_at.nil?
  end

  def duration
    return nil if end_time.nil?

    start_time = self.start_time.split(':').map(&:to_f)
    end_time = self.end_time.split(':').map(&:to_f)
    (end_time[0] - start_time[0]) + ((end_time[1] - start_time[1]) / 60.0)
  end

  def next_occurrences_after first_datetime, limit: 10
    first_date = first_datetime.to_date
    return [] if registration_end_time && registration_end_time < first_datetime

    occurrences = []
    
    date = start_date > first_date ? start_date : first_date
    time = start_time.split(':').map(&:to_i)
    datetime = date.to_time(:utc).in_time_zone(venue.time_zone).change(hour: time[0], min: time[1])

    if recurrence == 'day'
      if datetime > first_datetime
        occurrences.push(datetime)
      else
        occurrences.push(datetime + 1.day)
      end
    else
      next_datetime = (datetime + 1.week).beginning_of_week(recurrence.to_sym)
      next_datetime = next_datetime.change(hour: time[0], min: time[1])
      occurrences.push(next_datetime)
    end

    return occurrences if course_category?

    while occurrences.length < limit
      next_datetime = occurrences.last + (recurrence == 'day' ? 1.day : 1.week)
      break if end_date && next_datetime.to_date > end_date

      occurrences.push(next_datetime)
    end

    occurrences
  end

  def next_occurrence_at
    @next_occurrence_at ||= next_occurrences_after(Time.now, limit: 1).first
  end

  def registration_end_time
    @registration_end_time ||= begin
      if %i[course single concert].include?(category)
        Time.parse("#{start_date} #{start_time}")
      elsif end_date?
        Time.parse("#{end_date} #{start_time}")
      end
    end
  end

  def label
    custom_name || venue.street
  end

  def log_status_change
    return if archived? || new_record?
    
    if needs_urgent_review?
      parent_managers.each do |parent_manager|
        EventMailer.with(event: self, manager: parent_manager).status.deliver_later
      end
    end

    EventMailer.with(event: self, manager: self.manager).status.deliver_later
  end

  def cache_key
    "#{super}-#{status}-#{last_activity_on.strftime("%d%m%Y")}"
  end

  def manager_verified?
    manager.email_verified?
  end

  def default_language_code
    language_code || location.country.default_language_code || I18n.locale.upcase
  end

  def parent_managers
    parent.managers
  end

  def self.model_name
    ActiveModel::Name.new(base_class)
  end

  private

    def validate_end_time
      return if end_time.nil? || duration.positive?
      
      self.errors.add(:end_time, I18n.translate('cms.messages.event.invalid_end_time'))
    end

    def validate_end_date
      self.end_date = start_date if recurrence == 'day' && !end_date.present?
      return if end_date.nil?
      
      self.errors.add(:end_date, I18n.translate('cms.messages.event.invalid_end_date')) if end_date < start_date
      # self.errors.add(:end_date, I18n.translate('cms.messages.event.passed_end_date')) if end_date < Date.today
    end

    def parse_phone_number
      self.phone_number = Phonelib.parse(phone_number, location.country_code).international
    end

    def verify_manager
      return if manager.email_verified?

      ManagerMailer.with(manager: manager, context: self).verify.deliver_later
      manager.touch(:email_verification_sent_at)
    end

end
