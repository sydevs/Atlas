module CMS::ApplicationHelper

  ALERT_ICONS = {
    urgent_review: 'red warning sign',
    review: 'orange warning sign',
    recently_expired: 'warning sign',
    expired: 'info circle',
  }.freeze

  PLACE_MODELS = %i[
    countries
    regions
    areas
  ]

  def floating_action text, icon = nil, url = nil, **args
    klass = %w[ui basic right floated compact tiny button]
    klass << args[:class] if args[:class].present?
    content_tag :a, class: klass, href: url, **args.except(:class) do
      concat tag.i class: "#{icon} icon" if icon
      concat text
    end
  end

  def menu_item label, record, index: nil, action: nil
    active = [controller_name, action_name].include?(index) if index
    active = action_name == action if action

    if action.present?
      content_tag :a, label, class: "#{'active' if active} item", href: action == 'show' ? url_for([:cms, record || :worldwide]) : url_for([action.to_sym, :cms, record])
    elsif controller.present?
      content_tag :a, label, class: "#{'active' if active} item", href: url_for([:cms, record, index.to_sym])
    else
      content_tag :div, label, class: 'item'
    end
  end

  def alert_icon type
    content_tag :i, nil, class: "#{ALERT_ICONS[type]} icon"
  end

  def breadcrumb_url ancestor
    if action_name == 'index' && PLACE_MODELS.include?(controller_name.to_sym)
      PLACE_MODELS.each do |model|
        return url_for([:cms, ancestor, model]) if policy(ancestor).index_association?(model)
      end
    elsif @context.is_a?(Manager) && !ancestor.is_a?(Event)
      url_for([:cms, ancestor, :managers])
    elsif action_name == 'index' && policy(ancestor).index_association?(controller_name.to_sym)
      url_for([:cms, ancestor, controller_name.to_sym])
    else
      url_for([:cms, ancestor])
    end
  end

  def help_link type, title = nil
    content_tag :div, class: 'ui help' do
      tag.a href: cms_help_url(q: type, anchor: type), target: '_blank' do
        concat tag.i class: 'info circle icon'
        concat title || translate("cms.help.#{type}.title")
      end
    end
  end

  def record_link record, **kwargs
    if policy(record).show?
      tag.a record.label, href: url_for([:cms, record]), **kwargs
    else
      tag.span record.label, **kwargs
    end
  end

  def active_accordion? type
    'active' if params[:q]&.to_sym == type # || (params[:q].nil? && type == :guide)
  end

  def time_from_now_in_words time
    time > Time.now ? time_ago_in_words(time) : translate('datetime.distance_in_words.soon')
  end

  def expiry_time_in_words status
    return nil unless Expirable::TRANSITION_STATE_AFTER.key?(status)

    duration = Expirable::TRANSITION_STATE_AFTER[status]

    if ENV['TEST_EMAILS']
      translate('datetime.distance_in_words.x_minutes', count: duration.in_minutes.to_i)
    else
      translate('datetime.distance_in_words.x_weeks', count: duration.in_weeks.to_i)
    end
  end

  def markdown content
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    @markdown.render(content).html_safe
  end

end
