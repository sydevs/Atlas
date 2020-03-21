class ManagedRecord < ApplicationRecord

  belongs_to :record, polymorphic: true
  belongs_to :manager
  searchable_columns %w[managers.name managers.email]

  after_create do |record|
    Manager.set_counter(record_type, :increment, manager_id)
  end

  after_destroy do |record|
    Manager.set_counter(record_type, :decrement, manager_id)
  end

  def managed_by? user
    assigned_by_id == user.id
  end

end
