
class ManagerPolicy < DatabasePolicy

  def destroy?
    user.administrator? && @context.present?
  end

  def new_association? association = nil
    false
  end

  def index_association? association = nil
    return false if association == :audits
    return super
  end

  def view_activity?
    manage? super_manager: true
  end

end
