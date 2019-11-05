class AuditPolicy < DatabasePolicy

  def create?
    false
  end

end
