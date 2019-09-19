class Manager < ApplicationRecord

  passwordless_with :email

  has_many :managed_regions
  has_many :countries, through: :managed_regions, source: :region, source_type: 'Regions::Country'
  has_many :provinces, through: :managed_regions, source: :region, source_type: 'Regions::Province'
  has_many :local_areas, through: :managed_regions, source: :region, source_type: 'Regions::LocalArea'

  has_many :venues
  has_many :events
  has_many :registrations, through: :events

  accepts_nested_attributes_for :managed_regions
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def managed_by? manager, super_manager: false
    return true if self == manager && !super_manager
    return manager.administrator?
    # TODO: Allow managers to manage other users within their own regions.
  end

end
