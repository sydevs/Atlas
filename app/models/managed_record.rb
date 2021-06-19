class ManagedRecord < ApplicationRecord

  # Extensions
  searchable_columns %w[managers.name managers.email]

  # Associations
  belongs_to :record, polymorphic: true
  belongs_to :manager

  # Scopes
  scope :created_since, ->(since) { where('created_at >= ?', since) }

  # Methods

  after_create do |record|
    Manager.set_counter(record_type, :increment, manager_id)

    if manager.new_record?
      ManagerMailer.with(manager: manager, context: record).welcome.deliver_later
    else
      ManagedRecordMailer.with(managed_record: self).created.deliver_later
    end
  end

  after_destroy do |record|
    Manager.set_counter(record_type, :decrement, manager_id)
  end

  def managed_by? user
    assigned_by_id == user.id
  end

end
