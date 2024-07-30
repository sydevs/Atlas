class RegistrationPolicy < DatabasePolicy

  def new?
    false
  end

  def create?
    true
  end

  def edit?
    false
  end

  def index_association? association = nil
    return false if association == :audits && !user.administrator?
    return false if association == :conversations

    super
  end

end
