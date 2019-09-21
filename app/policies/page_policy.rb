
class PagePolicy < Struct.new(:user, :page)
  def dashboard?
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
