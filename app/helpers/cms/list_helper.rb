module CMS::ListHelper

  MODEL_ICONS = {
    countries: 'globe americas',
    regions: 'map',
    areas: 'dot circle',
    venues: 'map marker',
    events: 'calendar',
    managers: 'user secret',
    registrations: 'user',
    audits: 'clipboard list',
    clients: 'broadcast tower',
    pictures: 'image',
    messages: 'comment',
  }.freeze

  MANAGER_ICONS = {
    worldwide: 'chess queen',
    country: 'chess bishop',
    local: 'chess knight',
    event: 'chess pawn',
    client: 'chess rook',
    none: 'minus',
  }.freeze

  NOTICE_COLORS = {
    finished: 'black',
    archived: 'black',
    expired: 'orange',
    unverified: 'orange',
    published: 'green',
  }.freeze

  NOTICE_ICONS = {
    finished: 'check circle',
    archived: 'times circle',
    expired:  'exclamation circle',
    unverified: 'question circle',
    published: 'check circle',
    unpublished: 'dot circle',
  }.freeze

  NOTICE_MESSAGE = {
    finished: 'record_finished',
    archived: 'record_archived',
    expired: 'manager_not_verified',
    unverified: 'record_expired',
    unpublished: 'record_not_published',
  }.freeze

  def model_icon model
    content_tag :i, nil, class: "#{MODEL_ICONS[model.table_name.to_sym]} icon"
  end

  def manager_icon manager_or_type
    type = manager_or_type.is_a?(Manager) ? manager_or_type.type : manager_or_type
    content_tag :i, nil, class: "#{MANAGER_ICONS[type]} icon"
  end

  def notice_type event
    if event.should_finish?
      :finished
    elsif event.archived?
      :archived
    elsif event.expired?
      :expired
    elsif !event.manager_verified?
      :unverified
    elsif event.published?
      :published
    elsif !event.published?
      :unpublished
    end
  end

  def notice_color type
    NOTICE_COLORS.fetch(type, 'grey')
  end

  def notice_icon type
    icon = NOTICE_ICONS.fetch(type, 'dot circle')
    content_tag :i, nil, class: "#{notice_color(type)} #{icon} icon"
  end

  def notice_message type, model = Event
    translate("cms.details.#{NOTICE_MESSAGE[type]}.title", resource: translate_model(model))
  end

end
