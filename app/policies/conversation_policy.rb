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

  def reply?
    return false if record.messages.last.person == user

    user.administrator? || record.members.include?(user)
  end
  
  def index_association? association = nil
    return false if association == :managers
    return false if association == :users

    super
  end

end
