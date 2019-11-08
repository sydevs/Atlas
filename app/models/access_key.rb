class AccessKey < ApplicationRecord

  # Extensions
  include Searchable

  searchable_columns %w[label]
  audited

  # Validations
  validates_presence_of :label
  validates_presence_of :key

  # Scopes
  default_scope { order(last_accessed_at: :desc, updated_at: :desc) }
  scope :active, -> { where(suspended: true) }
  scope :suspended, -> { where(suspended: true) }

end
