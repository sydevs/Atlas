class ManagerPolicy < DatabasePolicy

  def dashboard?
    user == record
  end

  def resend_verification?
    manage? && (!record.email_verification_sent_at || record.email_verification_sent_at < 5.minutes.ago)
  end

  def destroy?
    user.administrator? && user != record
  end

  def new_association? _association = nil
    false
  end

  def index_association? association = nil
    return false if association == :audits
    return false if %i[clients countries regions areas].include?(association)
    return false if association == :events && record.type == :worldwide
    return false if association == :managed_records && %i[worldwide event none].include?(record.type)

    super
  end

  def view_activity?
    manage?(super_manager: true)
  end

end
