class ManagerPolicy < DatabasePolicy

  def destroy?
    user.administrator?
  end

  def new_association? _association = nil
    false
  end

  def index_association? association = nil
    return false if association == :audits

    super
  end

  def view_activity?
    manage? super_manager: true
  end

end
