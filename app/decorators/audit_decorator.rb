module AuditDecorator

  CATEGORY_ICONS = {
    notice_sent: 'bell',
    record_updated: 'pen square',
    record_created: 'plus square',
  }

  def label
    translate(category, scope: 'cms.audits.title', model: translate_model(parent))
  end

  def icon
    if CATEGORY_ICONS.key?(category.to_sym)
      tag.div(tag.i(class: "#{CATEGORY_ICONS[category.to_sym]} icon"), class: 'label')
    elsif person.present? && !status_verified?
      tag.div(class: 'label', data: { text: initials }, style: "--background: #{background_color}; --color: #{text_color}")
    elsif status.present?
      status_icon(status)
    else
      tag.div(tag.i(class: 'circle icon'), class: 'label')
    end
  end

  def description context: nil
    args = {
      model: translate_model(parent).downcase,
      status: status ? status_label(status) : nil
    }

    if person
      if policy(person).show?
        args[:person] = link_to(person.name, url_for([:cms, person]))
      else
        args[:person] = person.name
      end
    end
  
    if policy(parent).show?
      args[:resource] = link_to(parent.label, url_for([:cms, parent]))
    elsif parent.present?
      args[:resource] = parent.label
    else
      args[:resource] = translate_model(parent)
    end

    if context == parent || context.is_a?(Conversation)
      translate(category, scope: 'cms.audits.contextual_summary', **args).upcase_first.html_safe
    else
      translate(category, scope: 'cms.audits.summary', **args).upcase_first.html_safe
    end
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
