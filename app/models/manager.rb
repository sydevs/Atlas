class Manager < ApplicationRecord

  passwordless_with :email

  has_many :managed_regions
  has_many :countries, through: :managed_regions, source: :region, source_type: 'Country'
  has_many :provinces, through: :managed_regions, source: :region, source_type: 'Province'
  has_many :local_areas, through: :managed_regions, source: :region, source_type: 'LocalArea'

  has_many :venues
  has_many :events

  accepts_nested_attributes_for :managed_regions
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  searchable_columns %w[name email]

  def parent
    countries.first || local_areas.international.first || provinces.first || local_areas.cross_province.first || local_areas.first
  end

  def managed_by? manager, super_manager: false
    return true if self == manager && !super_manager
    return manager.administrator?
    # TODO: Allow managers to manage other users within their own regions.
  end

end
