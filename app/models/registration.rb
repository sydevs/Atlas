class Registration < ApplicationRecord

  belongs_to :event

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  default_scope { order(created_at: :desc) }

end
