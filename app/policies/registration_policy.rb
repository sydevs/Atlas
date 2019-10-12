
class RegistrationPolicy < DatabasePolicy
  
  def new?
    false
  end

  def create?
    true
  end

end
