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
  scope :since, -> (date) { where('created_at >= ?', date) }
  scope :group_by_month, -> { unscoped.group("DATE_TRUNC('month', created_at)") }
  scope :group_by_week, -> { unscoped.group("DATE_TRUNC('week', created_at)") }

  # Delegations
  alias parent event

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
