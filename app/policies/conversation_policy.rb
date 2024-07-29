class ConversationPolicy < DatabasePolicy

  def show?
    manage?
  end

  def new?
    false
  end

  def edit?
    false
  end

end
