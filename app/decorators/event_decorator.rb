module EventDecorator

  def decorated_location
    @location ||= (online? ? decorated_area : decorated_venue)
  end

  def decorated_area
    @area ||= begin
      area.extend(AreaDecorator)
    end
  end

  def decorated_venue
    @venue ||= begin
      venue.extend(VenueDecorator)
    end
  end

  def label
    if custom_name.present? && language_code.to_sym == I18n.locale.to_sym
      custom_name
    elsif inactive_category?
      I18n.translate('api.event.inactive_label', category: category_label, area: decorated_area.label)
    elsif online?
      I18n.translate('api.event.online_label', category: category_label, area: decorated_area.label)
    else
      I18n.translate('api.event.label', category: category_label, venue: decorated_venue.label)
    end
  end

  def address
    [room, decorated_location.address].compact.join(', ')
  end

  def category_name
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.categories') : nil
  end

  def category_label
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.category_labels') : nil
  end

  def category_description
    category ? I18n.translate(category, scope: 'activerecord.attributes.event.category_descriptions') : nil
  end

  def recurrence_in_words parts=%i[recurrence timing dates], short: false
    return nil if inactive_category?

    parts.map! do |key|
      case key
      when :recurrence
        wday = I18n.translate(recurrence.starts_at.wday, scope: %i[map weekdays])
        I18n.translate recurrence_type, scope: "activerecord.attributes.recurrable.descriptions", locale: I18n.locale, weekday: wday
      when :timing
        if short
          recurrence_data['start_time']
        else
          timing = [
            recurrence_data['start_time'],
            recurrence_data['end_time']
          ]

          if !timing[1].present? || timing[0] == timing[1]
            timing[0]
          else
            timing.join(" - ")
          end
        end
      when :dates
        month = short ? '%b' : '%B'
        base_format = "%-d #{month}"
        base_format += ' %Y' unless short && recurrence.starts_at.year == Time.now.year
        return recurrence.starts_at.strftime(base_format) if recurrence.infinite? || recurrence.starts_at.strftime(base_format) == recurrence.ends_at.strftime(base_format)

        start_format = '%-d'
        start_format += " #{month}" unless recurrence.starts_at.month == recurrence.ends_at.month
        start_format += ' %Y' unless recurrence.starts_at.year == recurrence.ends_at.year
        base_format += ' %Y' if recurrence.starts_at.year == Time.now.year && recurrence.starts_at.year != recurrence.ends_at.year

        [
          recurrence.starts_at.strftime(start_format),
          recurrence.ends_at.strftime(base_format)
        ].join(" - ")
      end
    end

    parts.reject(&:nil?).join(", ")
  end

  def description_html
    return nil unless description.present?
    
    helpers = ActionController::Base.helpers
    description = helpers.simple_format self[:description]
    helpers.auto_link(description, link: :urls, html: { target: '_blank', rel: 'nofollow' }) do |text|
      text = text.delete_prefix("http://").delete_prefix("https://").delete_prefix("www.")
      text = text.split("/", 2)
      text[1] = helpers.truncate(text[1], length: 15) if text.count > 1
      text.join("/")
    end
  end

  def contact_text
    if contact_info['phone_number'].present?
      "#{contact_info['phone_name']} (#{contact_info['phone_number']})"
    elsif contact_info['email_address'].present?
      contact_info['email_address']
    end
  end

  def recommendations
    return {} if expired? || archived? || finished?

    result = {}
    result[:description] = cms_url(:edit_cms_event_url) unless description.present?
    result[:pictures] = cms_url(:cms_event_pictures_url) unless pictures.count >= 3
    result[:registration] = cms_url(:edit_cms_event_url) unless native_registration_mode?
    result
  end

  def language_name
    LocalizationHelper.language_name(language_code.to_s.upcase) || translate('cms.hints.unspecified')
  end

  def map_path
    return nil unless publicly_visible?
    
    Rails.application.routes.url_helpers.event_path(self)
  end

  def map_url
    return nil unless publicly_visible?
    
    Rails.application.routes.url_helpers.event_url(self, host: ENV.fetch('ATLAS_REACT_HOST'))
  end

  def cms_url(url, **url_options)
    default_url_options = Rails.application.config.action_mailer.default_url_options
    Rails.application.routes.url_helpers.send(url, self, **url_options, **default_url_options)
  end

end
