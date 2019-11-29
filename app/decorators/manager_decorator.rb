module ManagerDecorator

  def label
    name
  end

  def home_url
    administrator? ? cms_root_url : cms_manager_url(self)
  end

end
