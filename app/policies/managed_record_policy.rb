class ManagedRecordPolicy < DatabasePolicy

  def destroy?
    user.administrator? || user.id == record.assigned_by_id
  end

end
