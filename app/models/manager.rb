class Manager < ApplicationRecord

  # Extensions
  passwordless_with :email
  searchable_columns %w[name email]
  audited except: %i[summary_email_sent_at]

  # Associations
  has_many :managed_records, dependent: :delete_all
  has_many :countries, through: :managed_records, source: :record, source_type: 'Country', dependent: :destroy
  has_many :provinces, through: :managed_records, source: :record, source_type: 'Province', dependent: :destroy
  has_many :local_areas, through: :managed_records, source: :record, source_type: 'LocalArea', dependent: :destroy
  has_many :local_area_venues, through: :local_areas, source: :venues
  has_many :local_area_provinces, through: :local_areas, source: :province
  has_many :events
  has_many :actions, class_name: 'Audit', as: :user

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Scopes
  default_scope { order(updated_at: :desc) }
  scope :administrators, -> { where(administrator: true) }
  scope :country_managers, -> { where('managed_countries_counter > 0') }
  scope :local_managers, -> { where('managed_localities_counter > 0') }
  scope :event_managers, -> { joins(:events) }
  scope :no_recent_email_sent, -> { where("summary_email_sent_at IS NULL OR summary_email_sent_at <= ?", Expirable.date_for(:interval)) }

  # Methods

  def parent
    case type
    when :country
      parent = countries.first
    when :local
      parent = local_areas.international.first || provinces.first || local_areas.cross_province.first || local_areas.first
    when :event
      parent = events.first
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
      events_via_countries = Event.joins(:venue).where(venues: { country_code: countries.select(:country_code) })
      events_via_provinces = Event.joins(:venue).where(venues: { province_code: provinces.select(:province_code) })
      events_via_local_areas = Event.joins(:venue).where(venues: { province_code: local_area_venues.select(:province_code) })
      Event.joins(:venue).where(id: events).or(events_via_countries).or(events_via_provinces).or(events_via_local_areas)
    end
  end

end
