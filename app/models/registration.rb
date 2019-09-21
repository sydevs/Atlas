class Registration < ApplicationRecord

  belongs_to :event

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  default_scope { order(created_at: :desc) }
  scope :recent, -> { where('created_at > ?', 30.days.ago) }
  searchable_columns %w[name email]
  alias_method :parent, :event

end
