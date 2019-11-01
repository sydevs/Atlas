class AccessKeyPolicy < DatabasePolicy

  def manage? **_args
    user.administrator?
  end

end
