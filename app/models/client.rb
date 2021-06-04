class Client < ApplicationRecord

  # Extensions
  include Searchable
  include Managed

  searchable_columns %w[label domain]
  audited

  # Validations
  validates_presence_of :label, :domain, :public_key, :secret_key

  # Scopes
  default_scope { order(last_accessed_at: :desc, updated_at: :desc) }
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Callbacks
  before_validation :find_manager
  after_save :find_or_create_manager

end
