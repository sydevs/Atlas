class ManagedRecord < ApplicationRecord

  # Extensions
  searchable_columns %w[managers.name managers.email]

  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :manager

  # Scopes
  scope :created_since, ->(since) { where('created_at >= ?', since) }

  # Methods

  def managed_by? user
    assigned_by_id == user.id
  end

end
