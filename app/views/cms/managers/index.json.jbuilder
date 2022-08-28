json.success true
json.query params[:q]

json.categories do
  json.array! ["managers", "invite"]
end

json.results do
  json.managers do
    json.name translate('cms.hints.event.manager.categories.managers')
    json.results do
      json.array! @records do |manager|
        json.category 'manager'
        json.title manager.name
        json.description [manager.email, manager.phone].compact.join(' • ')

        json.id manager.id
        json.name manager.name
        json.email manager.email
        json.phone manager.phone
        json.language_code manager.language_code
      end
    end
  end

  if !@exact_match
    json.invite do
      json.name translate('cms.hints.event.manager.categories.invite')
      json.results do
        if @email_match
          json.child! do
            json.category 'invite'
            json.title translate('cms.hints.event.manager.short_invitations.email')
            json.alt_title translate('cms.hints.event.manager.invitations.email')
            json.description @email_match

            json.email @email_match
            json.contact_method :email
          end
        end
        
        if @phone_match && false # TODO: Implement this
          Manager.contact_methods.keys.excluding('email').each do |key|
            json.child! do
              json.category 'invite'
              json.title translate('cms.hints.event.manager.short_invitations.phone', messenger: translate_enum_value(Manager, :contact_method, key))
              json.alt_title translate('cms.hints.event.manager.invitations.phone', messenger: translate_enum_value(Manager, :contact_method, key))
              json.description @phone_match
              json.image image_url("cms/#{key}.svg")

              json.phone @phone_match
              json.contact_method key
            end
          end
        end
      end
    end
  end
end