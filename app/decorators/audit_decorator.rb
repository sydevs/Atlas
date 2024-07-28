module AuditDecorator

  def label
    translate(category, scope: 'cms.audits.title', model: translate_model(parent))
  end

  def initials
    @initials ||= person&.name&.split&.map(&:first)&.join('')&.upcase
  end

  def background_color
    @background_color ||= begin
      seed = Random.new(person_id || parent_id).rand
      "#" + "%06x" % (seed * 0xffffff)
    end
  end

  def text_color
    @text_color ||= begin
      rgb = background_color.match(/^#(..)(..)(..)$/).captures.map(&:hex)
      (rgb[0]*0.299 + rgb[1]*0.587 + rgb[2]*0.114) > 186 ? "#000000" : "#ffffff"
    end
  end

end
