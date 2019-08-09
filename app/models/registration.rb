require 'csv'

class Registration < ApplicationRecord

  belongs_to :event

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  default_scope { order(created_at: :desc) }

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
