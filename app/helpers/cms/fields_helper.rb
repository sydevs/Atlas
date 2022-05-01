module CMS::FieldsHelper
  
  CONTACT_TYPE_ICONS = {
    new_managed_record: 'plus circle',
    event_verification: 'check circle',
    event_registrations: 'calendar alternate',
    region_summary: 'dot circle',
    country_summary: 'compass',
    application_summary: 'world',
  }.freeze

  EVENT_CATEGORY_ICONS = {
    dropin: 'calendar',
    single: 'calendar outline',
    course: 'calendar alternate',
    festival: 'dumpster',
    concert: 'microphone alternate',
  }.freeze

  def contact_types manager
    result = %i[new_managed_record event_verification]
    result << :event_registrations if manager.events.present?
    result << :region_summary if manager.provinces.present? || manager.local_areas.present?
    result << :country_summary if manager.countries.present?
    result << :application_summary if manager.administrator?
    # result << :client_summary if manager.clients.present?
    result
  end
  
  def contact_type_icon type
    CONTACT_TYPE_ICONS[type]
  end
  
  def contact_type_summary_period type
    case type
    when :region_summary
      distance_of_time_in_words(RegionMailer::SUMMARY_PERIOD)
    when :country_summary
      distance_of_time_in_words(CountryMailer::SUMMARY_PERIOD)
    when :application_summary
      distance_of_time_in_words(ApplicationMailer::SUMMARY_PERIOD)
    end
  end
  
  def event_category_icon category
    EVENT_CATEGORY_ICONS[category.to_sym]
  end
  
end