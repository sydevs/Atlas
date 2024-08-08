require 'csv'

class User < ApplicationRecord

  # Extensions
  searchable_columns %w[name email]

  # Associations
  has_many :registrations

  # Validations
  validates :name, presence: true
  validates :email, presence: true #, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Methods

  def first_name
    name.split(' ', 2).first
  end

  def last_name
    split = name.split(' ', 2)
    split.last if split.length > 1
  end

end
