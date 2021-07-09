class ClientPolicy < DatabasePolicy

  def set_manager?
    manage? super_manager: true
  end

end
