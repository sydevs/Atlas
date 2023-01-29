require 'csv'

class Registration < ApplicationRecord

  # Extensions
  searchable_columns %w[name email]

  # Associations
  belongs_to :event

  # Validations
  validates :name, presence: true
  validates :email, presence: true #, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :starting_at, presence: true

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :since, -> (date) { where('registrations.created_at >= ?', date) }
  scope :group_by_month, -> { reorder(nil).group("DATE_TRUNC('month', registrations.created_at)") }
  scope :group_by_week, -> { reorder(nil).group("DATE_TRUNC('week', registrations.created_at)") }
  scope :order_comments_first, -> do 
    r = Registration.arel_table
    reorder(r[:comment].eq(nil)).order(r[:created_at].asc)
  end

  # Delegations
  alias parent event
  delegate :immediate_registration_notification?, to: :event

  # Callbacks
  after_create :send_registrations_notification, if: :immediate_registration_notification?

  # Methods

  def first_name
    name.split(' ', 2).first
  end

  def last_name
    split = name.split(' ', 2)
    split.last if split.length > 1
  end

  def starting_date
    starting_at.to_date
  end

  def subscribe_to! list_id
    SendinblueAPI.subscribe(email, list_id, {
      email: email,
      firstname: first_name,
      lastname: last_name,
      timezone: time_zone,
      city: event.area&.name,
      state_region: event.area&.region&.name,
      country: event.area&.country&.name,
      how_they_joined: "Sahaj Atlas Registration",
      language: LocalizationHelper.language_name(event.language_code),
      latitude: (event.venue&.latitude || event.area&.latitude),
      longitude: (event.venue&.longitude || event.area&.longitude),
    })
  end

  def self.to_csv
    attributes = %w[id name email created_at comment]

    ::CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  private

    def send_registrations_notification
      EventMailer.with(event: event, test: true).registrations.deliver_now
      # EventMailer.with(event: event, manager: event.manager).registrations.deliver_later
    end

end
