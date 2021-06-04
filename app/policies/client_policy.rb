class ClientPolicy < DatabasePolicy

  def show?
    false
  end

  def set_manager?
    manage? super_manager: true
  end

  def manage? **_args
    user.administrator?
  end

end
