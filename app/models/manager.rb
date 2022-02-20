class Manager < ApplicationRecord

  # Extensions
  passwordless_with :email
  searchable_columns %w[name email phone]
  audited

  enum contact_method: { email: 0, whatsapp: 1, telegram: 2, wechat: 3 }, _prefix: :contact_by
  flag :notifications, %i[new_managed_record event_verification event_registrations region_summary country_summary application_summary client_summary]

  # Associations
  has_many :managed_records, dependent: :delete_all
  has_many :countries, through: :managed_records, source: :record, source_type: 'Country', dependent: :destroy
  has_many :provinces, through: :managed_records, source: :record, source_type: 'Province', dependent: :destroy
  has_many :local_areas, through: :managed_records, source: :record, source_type: 'LocalArea', dependent: :destroy
  has_many :local_area_venues, through: :local_areas, source: :venues
  has_many :local_area_provinces, through: :local_areas, source: :province
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
  scope :country_managers, -> { where('managed_countries_counter > 0') }
  scope :local_managers, -> { where('managed_localities_counter > 0') }
  scope :event_managers, -> { joins(:events) }
  scope :client_managers, -> { joins(:clients) }

  # Methods
  before_save :unverify

  def parent
    case type
    when :country
      parent = countries.first
    when :local
      parent = local_areas.international.first || provinces.first || local_areas.cross_province.first || local_areas.first
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

  def type
    if administrator?
      :worldwide
    elsif managed_countries_counter.positive?
      :country
    elsif managed_localities_counter.positive?
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

  def set_counter record, direction
    Manager.set_counter
  end

  def self.set_counter klass, direction, id
    if klass == 'Country'
      column = :managed_countries_counter
    elsif klass == 'Event'
      column = :managed_events_counter
    elsif %w[Province LocalArea].include?(klass)
      column = :managed_localities_counter
    end

    Manager.send("#{direction}_counter", column, id) if column
  end
  
  def accessible_countries area: false
    if administrator? || area
      Country.default_scoped
    else
      countries_via_province = Country.where(country_code: provinces.select(:country_code))
      countries_via_local_area = Country.where(country_code: local_areas.select(:country_code))
      countries_via_event = Country.where(country_code: events.select(:country_code))
      Country.where(id: countries).or(countries_via_province).or(countries_via_local_area).or(countries_via_event)
    end
  end
  
  def accessible_provinces country_code = nil, area: false
    if administrator? || area
      country_code ? Province.where(country_code: country_code) : Province.default_scoped
    elsif country_code
      Province.where(id: provinces, country_code: country_code)
    else
      provinces_via_country = Province.where(country_code: countries.select(:country_code).where(enable_province_management: true))
      provinces_via_local_area = Province.where(id: local_area_provinces)
      provinces_via_event = Province.where(province_code: events.select(:province_code))
      Province.where(id: provinces).or(provinces_via_country).or(provinces_via_local_area).or(provinces_via_event)
    end
  end

  def accessible_events
    if administrator?
      Event.default_scoped
    else
      events_via_countries = Event.joins(:venue).left_outer_joins(:local_areas).where(venues: { country_code: countries.select(:country_code) })
      events_via_provinces = Event.joins(:venue).left_outer_joins(:local_areas).where(venues: { province_code: provinces.select(:province_code) })
      events_via_local_areas = Event.joins(:venue).left_outer_joins(:local_areas).where(local_areas: { id: local_areas.select(:id) })
      Event.joins(:venue).left_outer_joins(:local_areas).where(id: events).or(events_via_countries).or(events_via_provinces).or(events_via_local_areas)
    end
  end

  def verified?
    email_verified? || phone_verified?
  end

  private

    def unverify
      self[:email_verified] = false if email_changed?
      self[:phone_verified] = false if phone_changed?
    end

end
