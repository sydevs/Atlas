class Region < ApplicationRecord

  has_many :venues
  has_many :events, through: :venues
  has_and_belongs_to_many :managers

  enum restriction: { no: 0, subnational: 1, country: 2 }

  validates :country, presence: true, if: :subnational?
  validates :latitude, presence: true, if: :local?
  validates :longitude, presence: true, if: :local?
  validates :radius, presence: true, if: :local?

  def local?
    latitude? || longitude? || radius?
  end

  def subnational?
    subnational.present?
  end

  def country?
    country_code.present?
  end

end
