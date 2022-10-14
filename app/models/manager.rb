class Manager < ApplicationRecord

  # Extensions
  passwordless_with :email
  searchable_columns %w[name email phone]
  audited except: %i[last_login_at]

  enum contact_method: { email: 0, whatsapp: 1, telegram: 2, wechat: 3 }, _prefix: :contact_by
  flag :notifications, %i[new_managed_record event_verification event_registrations place_summary country_summary application_summary client_summary]

  # Associations
  has_many :managed_records, dependent: :delete_all
  has_many :countries, through: :managed_records, source: :record, source_type: 'Country', dependent: :destroy
  has_many :regions, through: :managed_records, source: :record, source_type: 'Region', dependent: :destroy
  has_many :areas, through: :managed_records, source: :record, source_type: 'Area', dependent: :destroy
  has_many :area_venues, through: :areas, source: :venues
  has_many :area_regions, through: :areas, source: :region
  has_many :venues, through: :events
  has_many :events
  has_many :clients
  has_many :actions, class_name: 'Audit', as: :user

  # Validations
  before_validation { self.email = self.email&.downcase }
  before_validation { self.phone = Phonelib.parse(phone).international if phone }
  validates_presence_of :name, :language_code
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_presence_of :email, if: :contact_by_email?
  validates_presence_of :phone, unless: :contact_by_email?

  # Scopes
  default_scope { order(updated_at: :desc) }
  scope :administrators, -> { where(administrator: true) }
  scope :country_managers, -> {joins(:countries) }
  scope :local_managers, -> { joins(:regions, :areas) }
  scope :event_managers, -> { joins(:events) }
  scope :client_managers, -> { joins(:clients) }

  # Callbacks
  before_save :unverify
  after_save :update_sendinblue, if: :email_previously_changed?

  # Methods

  def parent
    case type
    when :country
      parent = countries.first
    when :local
      parent = regions.first || areas.first
    when :event
      parent = events.first
    when :client
      parent = clients.first
    end
    
    parent unless parent&.new_record?
  end

  def managed_by? manager, super_manager: nil
    return true if self == manager && super_manager != true
    return true if manager.administrator? && super_manager != false

    false
  end

  def first_name
    name.split(' ', 2).first
  end

  def last_name
    split = name.split(' ', 2)
    split.last if split.length > 1
  end

  def type
    if administrator?
      :worldwide
    elsif countries.exists?
      :country
    elsif regions.exists? || areas.exists?
      :local
    elsif clients.exists?
      :client
    elsif events.exists?
      :event
    else
      :none
    end
  end

  # For audit logs
  def username
    name
  end

  def accessible_countries area: false
    if administrator? || area
      Country.default_scoped
    else
      countries_via_region = Country.where(country_code: regions.select(:country_code))
      countries_via_area = Country.where(country_code: areas.select(:country_code))
      countries_via_event = Country.where(country_code: events.select(:country_code))
      Country.where(id: countries).or(countries_via_region).or(countries_via_area).or(countries_via_event)
    end
  end
  
  def accessible_regions country_code = nil, area: false
    if administrator? || area
      country_code ? Region.where(country_code: country_code) : Region.default_scoped
    elsif country_code
      Region.where(id: regions, country_code: country_code)
    else
      regions_via_country = Region.where(country_code: countries.select(:country_code).where(enable_regions: true))
      regions_via_area = Region.where(id: area_regions)
      regions_via_venue = Region.where(id: area_venues)
      Region.where(id: regions).or(regions_via_country).or(regions_via_area).or(regions_via_venue)
    end
  end

  def accessible_events
    if !administrator?
      Event.default_scoped
    else
=begin
      # TODO: Fix this
      events_via_countries = Event.left_outer_joins(:areas).where(locations: { country_code: countries.select(:country_code) })
      events_via_regions = Event.left_outer_joins(:areas).where(locations: { province_code: regions.select(:province_code) })
      offline_events_via_areas = Event.left_outer_joins(:areas).where(areas: { id: areas.select(:id) })
      online_events_via_areas = Event.where(area_id: areas.select(:id))
      
      Event.left_outer_joins(:areas)
        .where(id: events)
        .or(events_via_countries)
        .or(events_via_regions)
        .or(offline_events_via_areas)
        .or(online_events_via_areas)
=end
      Event.default_scoped
    end
  end

  def verified?
    email_verified? || phone_verified?
  end

  def contact_by_messenger?
    !contact_by_email?
  end

  private

    def unverify
      self[:email_verified] = false if email_changed?
      self[:phone_verified] = false if phone_changed?
    end

    def update_sendinblue
      SendinblueAPI.update_contact(email_previously_was, {
        email: email,
        firstname: first_name,
        lastname: last_name,
      })
    end

end
