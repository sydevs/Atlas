class AuditPolicy < DatabasePolicy

  def new?
    false
  end

  def edit?
    false
  end

end
