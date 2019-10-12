class Manager < ApplicationRecord

  passwordless_with :email

  has_many :managed_records
  has_many :countries, through: :managed_records, source: :record, source_type: 'Country'
  has_many :provinces, through: :managed_records, source: :record, source_type: 'Province'
  has_many :local_areas, through: :managed_records, source: :record, source_type: 'LocalArea'
  has_many :venues, through: :managed_records, source: :record, source_type: 'Venue'
  has_many :events, through: :managed_records, source: :record, source_type: 'Event'

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  searchable_columns %w[name email]

  default_scope { order(updated_at: :desc) }

  def parent
    parent = countries.first || local_areas.international.first || provinces.first || local_areas.cross_province.first || local_areas.first || venues.first || events.first
    parent unless parent&.new_record?
  end

  def managed_by? manager, super_manager: false
    return true if self == manager && !super_manager
    return manager.administrator?
  end

  def to_s
    name
  end

end
