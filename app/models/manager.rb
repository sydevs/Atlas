class Manager < ApplicationRecord

  # Extensions
  passwordless_with :email
  searchable_columns %w[name email]
  audited

  # Associations
  has_many :managed_records
  has_many :countries, through: :managed_records, source: :record, source_type: 'Country', dependent: :destroy
  has_many :provinces, through: :managed_records, source: :record, source_type: 'Province', dependent: :destroy
  has_many :local_areas, through: :managed_records, source: :record, source_type: 'LocalArea', dependent: :destroy
  has_many :events, through: :managed_records, source: :record, source_type: 'Event', dependent: :destroy
  has_many :actions, class_name: 'Audit', foreign_type: :user_type, foreign_key: :user_id

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Scopes
  default_scope { order(updated_at: :desc) }
  scope :administrators, -> { where(administrator: true) }
  scope :country_managers, -> { where('managed_countries_counter > 0') }
  scope :local_managers, -> { where('managed_localities_counter > 0') }
  scope :event_managers, -> { where('managed_events_counter > 0') }

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

  def managed_by? manager, super_manager: false
    return true if self == manager && !super_manager

    manager.administrator?
  end

  def type
    if administrator?
      :worldwide
    elsif managed_countries_counter.positive?
      :country
    elsif managed_localities_counter.positive?
      :local
    elsif managed_events_counter.positive?
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
      Country.all
    else
      countries_via_province = Country.where(country_code: provinces.select(:country_code))
      countries_via_local_area = Country.where(country_code: local_areas.select(:country_code))
      Country.where(id: countries).or(countries_via_province).or(countries_via_local_area)
    end
  end
  
  def accessible_provinces country_code, area: false
    if administrator? || area
      Province.where(country_code: country_code)
    else
      provinces_via_local_area = Province.where(province_code: local_areas.select(:country_code))
      provinces = Province.where(id: provinces).or(provinces_via_local_area)
      Province.where(id: provinces, country_code: country_code)
    end
  end

end
