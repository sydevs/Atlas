class Manager < ApplicationRecord

  has_many :venues
  has_many :events
  has_many :registrations, through: :events

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

end
