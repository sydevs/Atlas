class UserPolicy < DatabasePolicy

  def show?
    false
  end

  def new?
    false
  end

  def edit?
    false
  end

end
