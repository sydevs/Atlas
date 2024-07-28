class Manager < ApplicationRecord

  # Extensions
  passwordless_with :email
  searchable_columns %w[name email phone]

  enum contact_method: { email: 0, whatsapp: 1, telegram: 2, wechat: 3 }, _prefix: :contact_by
  flag :notifications, %i[new_managed_record event_verification event_registrations place_summary country_summary application_summary client_summary]

  # Associations
  has_many :managed_records, dependent: :delete_all
  has_many :countries, through: :managed_records, source: :record, source_type: 'Country', dependent: :destroy
  has_many :regions, through: :managed_records, source: :record, source_type: 'Region', dependent: :destroy
  has_many :areas, through: :managed_records, source: :record, source_type: 'Area', dependent: :destroy
  has_many :area_venues, through: :areas, source: :venues
  has_many :area_regions, through: :areas, source: :region
  has_many :event_areas, through: :events, source: :areas
  # has_many :event_regions, through: :event_areas, source: :region
  has_many :venues, through: :events
  has_many :events
  has_many :clients
  has_many :actions, class_name: 'Audit', as: :person

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
  after_save :update_brevo!, if: :email_previously_changed?
  after_create :subscribe_to_brevo!
  after_destroy :unsubscribe_from_brevo!

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
    return true if parent&.managed_by?(manager)

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
      # regions_via_event = Region.where(id: event_regions)
      Region.where(id: regions).or(regions_via_country).or(regions_via_area) # .or(regions_via_event)
    end
  end
  
  def accessible_areas
    if administrator?
      Area.default_scoped
    else
      areas_via_country = Area.where(country_code: countries.select(:country_code))
      areas_via_region = Area.where(region_id: regions.select(:id))
      Area.where(id: areas).or(areas_via_country).or(areas_via_region)
    end
  end

  def accessible_events
    if administrator?
      Event.default_scoped
    else
      events_via_area = Event.where(area_id: accessible_areas.select(:id))
      Event.where(id: events).or(events_via_area)
    end
  end

  def verified?
    email_verified? || phone_verified?
  end

  def contact_by_messenger?
    !contact_by_email?
  end

  def update_brevo! update_management: false
    if email_previously_was.present?
      BrevoAPI.update_contact(email, brevo_attributes)
    elsif update_management
      BrevoAPI.update_contact(email, brevo_attributes)
    end
  end

  def subscribe_to_brevo!
    BrevoAPI.subscribe(email, :managers, brevo_attributes)
  end

  private

    def unverify
      self[:email_verified] = false if email_changed?
      self[:phone_verified] = false if phone_changed?
    end

    def brevo_attributes
      attributes = {
        email: email,
        firstname: first_name,
        lastname: last_name,
        timezone: areas.first&.time_zone,
        city: areas.first&.name,
        state_region: regions.first&.name,
        country: countries.first&.name,
        how_they_joined: "Sahaj Atlas Manager",
        language: LocalizationHelper.language_name(language_code),
        clients_managed: clients.pluck(:label).map{ |label| label+';' }.join,
        countries_managed: countries.pluck(:name).map{ |name| name+';' }.join,
        regions_managed: regions.pluck(:name).map{ |name| name+';' }.join,
        areas_managed: areas.pluck(:name).map{ |name| name+';' }.join,
        events_managed: events.joins(:venue).select(:custom_name, :venue_id, :'venues.street').map{ |e| e.label+';' }.join,
      }

      if administrator?
        attributes.merge!(
          clients_managed: 'ALL',
          countries_managed: 'ALL',
          regions_managed: 'ALL',
          areas_managed: 'ALL',
          events_managed: 'ALL',
        )
      end

      attributes
    end

    def unsubscribe_from_brevo!
      BrevoAPI.unsubscribe(email, :managers)
    end

end
