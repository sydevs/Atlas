
module CMS::ApplicationHelper

  MODEL_ICONS = {
    countries: 'globe americas',
    provinces: 'map',
    local_areas: 'dot circle',
    venues: 'map marker',
    events: 'calendar',
    managers: 'user',
    registrations: 'user',
    audits: 'clipboard list',
  }

  def floating_action text, icon, url = nil, **args
    klass = %w[ui basic right floated compact tiny button]
    klass << args[:class] if args[:class].present?
    content_tag :a, class: klass, href: url, **args.except(:class) do
      concat tag.i class: "#{icon} icon"
      concat text
    end
  end

  def menu_item label, record, index: nil, action: nil
    active = controller_name == index || action_name == index if index
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

end
