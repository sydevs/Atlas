class PagePolicy < Struct.new(:user, :page) # rubocop:disable Style/StructInheritance

  def database?
    user.present?
  end

  def statistics?
    user.present?
  end

  def map?
    true
  end

  def about?
    true
  end

end
