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

    if user == record
      return false if %i[event none].include?(user.type) && association == :regions
      return false if user.type == :none && association == :regions
    end

    super
  end

  def view_activity?
    manage?(super_manager: true)
  end

  def countries?
    user == record
  end

  def provinces?
    user == record
  end

  def clients?
    user == record
  end

end
