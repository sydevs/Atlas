module CMS::ApplicationHelper

  MODEL_ICONS = {
    countries: 'globe americas',
    provinces: 'map',
    local_areas: 'dot circle',
    venues: 'map marker',
    events: 'calendar',
    managers: 'user secret',
    registrations: 'user',
    audits: 'clipboard list',
    access_keys: 'key',
    pictures: 'image',
  }.freeze

  MANAGER_ICONS = {
    worldwide: 'chess queen',
    country: 'chess bishop',
    local: 'chess knight',
    event: 'chess pawn',
    none: 'minus',
  }.freeze

  ALERT_ICONS = {
    urgent_review: 'red warning sign',
    review: 'orange warning sign',
    recently_expired: 'warning sign',
    expired: 'info circle',
  }.freeze

  def floating_action text, icon, url = nil, **args
    klass = %w[ui basic right floated compact tiny button]
    klass << args[:class] if args[:class].present?
    content_tag :a, class: klass, href: url, **args.except(:class) do
      concat tag.i class: "#{icon} icon"
      concat text
    end
  end

  def menu_item label, record, index: nil, action: nil
    active = [controller_name, action_name].include?(index) if index
    active = action_name == action if action

    if active
      content_tag :div, label, class: 'active item'
    elsif action.present?
      content_tag :a, label, class: 'item', href: action == 'show' ? url_for([:cms, record || :root]) : url_for([action, :cms, record])
    elsif controller.present?
      content_tag :a, label, class: 'item', href: url_for([:cms, record, index])
    else
      content_tag :div, label, class: 'item'
    end
  end

  def model_icon model
    content_tag :i, nil, class: "#{MODEL_ICONS[model.table_name.to_sym]} icon"
  end

  def manager_icon manager
    content_tag :i, nil, class: "#{MANAGER_ICONS[manager.type]} icon"
  end

  def alert_icon type
    content_tag :i, nil, class: "#{ALERT_ICONS[type]} icon"
  end

  def breadcrumb_url ancestor
    # ancestor = current_user if ancestor == :home

    if action_name == 'index' && policy(ancestor).index_association?(controller_name)
      url_for([:cms, (ancestor == :dashboard ? nil : ancestor), controller_name])
    elsif action_name == 'regions' && policy(ancestor).index_association?(:regions)
      url_for([:cms, (ancestor == :dashboard ? nil : ancestor), :regions])
    elsif ancestor == :dashboard
      cms_root_url
    else
      url_for([:cms, ancestor])
    end
  end

end
