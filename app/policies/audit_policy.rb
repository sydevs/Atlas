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

  def reply?
    return false unless record.message? && !record.notice_sent?
    return false if record.person == user

    user.administrator? || record.conversation.members.include?(user)
  end

end
