class ManagedRecord < ActiveRecord::Base

  belongs_to :record, polymorphic: true
  belongs_to :manager

  after_create do |record|
    Manager.set_counter(record_type, :increment, manager_id)
  end

  after_destroy do |record|
    Manager.set_counter(record_type, :decrement, manager_id)
  end

end
