require 'csv'

class Registration < ApplicationRecord

  # Extensions
  searchable_columns %w[name email]

  # Associations
  belongs_to :event

  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :recent, -> { where('created_at > ?', 30.days.ago) }

  # Delegations
  alias_method :parent, :event

  # Methods

  def self.to_csv
    attributes = %w[id name email created_at comment]

    ::CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

end
