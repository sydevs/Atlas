
module AdminHelper

  def floating_action text, icon, url
    content_tag :a, class: 'ui right floated compact small button', href: url do
      concat tag.i class: "#{icon} icon"
      concat text
    end
  end

end
