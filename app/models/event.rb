class Event < ApplicationRecord

  # Extensions
  include Publishable
  include Expirable
  include ActivityMonitorable

  nilify_blanks
  searchable_columns %w[name description]
  audited except: %i[summary_email_sent_at upcoming_email_sent_at latest_registration_at]

  enum category: { intro: 1, intermediate: 2, course: 3, public_event: 4, concert: 5 }
  enum recurrence: { day: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }
  enum registration_mode: { native: 0, meetup: 1, eventbrite: 2 }, _suffix: true

  # Associations
  belongs_to :venue
  acts_as_mappable through: :venue

  has_many :pictures, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :pictures

  has_many :registrations, dependent: :delete_all

  belongs_to :manager
  accepts_nested_attributes_for :manager

  # Validations
  validates :custom_name, length: { maximum: 255 }
  validates :category, :language_code, presence: true
  validates :recurrence, :start_date, :start_time, presence: true
  validates :description, length: { minimum: 40, maximum: 600, allow_blank: true }
  validates :registration_url, url: true, unless: :native_registration_mode?
  validates :manager, presence: true
  validates :online_url, presence: true, if: :online?
  validates_associated :pictures

  # Scopes
  scope :with_new_registrations, -> { where('latest_registration_at >= summary_email_sent_at') }
  scope :notifications_enabled, -> { where.not(disable_notifications: true) }
  scope :publicly_visible, -> { published.not_expired.not_finished }
  scope :finished, -> { where('end_date IS NOT NULL AND end_date < ?', DateTime.now - 1.day) }
  scope :not_finished, -> { where('end_date IS NULL OR end_date >= ?', DateTime.now - 1.day) }

  scope :ready_for_status_email, -> { where("status_email_sent_at IS NULL OR status_email_sent_at <= ?", Expirable.date_for(:interval)) }
  scope :ready_for_reminder_email, -> { where("reminder_email_sent_at IS NULL OR reminder_email_sent_at <= ?", 12.hours.ago) }

  # Callbacks
  before_validation :find_manager
  before_validation :set_end_date
  after_save :find_or_create_manager
  after_save :notify_new_manager

  # Delegations
  delegate :full_address, to: :venue
  alias parent venue
  alias associated_registrations registrations

  # Methods
  attr_accessor :new_manager_record

  def managed_by? manager, super_manager: nil
    return true if super_manager != true && self.manager == manager
    return true if venue.managed_by?(manager) && super_manager != false

    false
  end

  def language_code= value
    # Only accept languages which are in the language list
    super value if I18nData.languages.key?(value)
  end

  def finished?
    end_date && end_date < DateTime.now - 1.day
  end

  def find_manager
    return unless manager.email.present?

    existing_manager = Manager.where(email: manager.email).first

    if existing_manager
      self.manager = existing_manager
    else
      self.manager_id = nil
    end
  end

  def find_or_create_manager
    return unless manager.email.present?

    self.new_manager_record = false

    self.manager = Manager.find_or_create_by(email: manager.email) do |new_manager|
      new_manager.name = manager.name
      self.new_manager_record = true
    end
  end

  def notify_new_manager
    return if self.new_manager_record
    return unless saved_change_to_attribute?(:manager_id)

    if created_at_changed?
      EventMailer.with(event: self).status.deliver_now
    else
      ManagedRecordMailer.with(event: self).created.deliver_now
    end
  end

  def next_recurrence_at
    @next_recurrence_at ||= begin
      return nil if end_date && end_date < Date.today

      date = start_date > Date.today ? start_date : Date.today
      time = start_time.split(':').map(&:to_i)
      datetime = date.to_time.change(hour: time[0], min: time[1])

      if datetime > Time.now
        datetime
      elsif recurrence == 'day'
        datetime + 1.day
      else
        (datetime + 1.week).beginning_of_week(recurrence.to_sym).change(hour: time[0], min: time[1])
      end
    end
  end

  def label
    custom_name || venue.street
  end

  private

    def set_end_date
      self.end_date = start_date if recurrence == 'day' && !end_date.present?
    end

end
