
class ManagerPolicy < DatabasePolicy

  def destroy?
    user.administrator? && @context.present?
  end

  def new_association? association = nil
    false
  end

end
