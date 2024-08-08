class AuditPolicy < DatabasePolicy

  def show?
    user.administrator? || record.changes.present?
  end

  def show_technical?
    user.administrator?
  end

  def new?
    false
  end

  def edit?
    false
  end

end
