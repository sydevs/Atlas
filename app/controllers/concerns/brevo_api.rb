
## BREVO
# This concern simplifies requests to brevo.com

module BrevoAPI
  include Rails.application.routes.url_helpers

  LISTS = {
    registrations: 13,
    managers: 19,
    test: 15,
  }.freeze

  TEMPLATES = {
    confirmation: 9,
    reminder: 12,
    followup: 205,
    status: 198,
    registrations: 201,
  }.freeze

  def self.subscribe email, list_id, attributes, api_key = nil
    return if Rails.env.development?

    client = Brevo::ContactsApi.new
    list_id = BrevoAPI::LISTS[list_id]

    # Create a contact
    p client.create_contact(
      'email' => email,
      'attributes' => attributes.deep_transform_keys { |key| key.to_s.upcase },
      'listIds' => [list_id.to_i],
      'updateEnabled' => true
    )
  rescue Brevo::ApiError => e
    puts "Exception when calling ContactsApi->create_contact: #{e} #{e.response_body}"
  end

  def self.unsubscribe email, list_id
    return if Rails.env.development?
    
    client = Brevo::ContactsApi.new
    list_id = BrevoAPI::LISTS[list_id]

    # Create a contact
    p client.remove_contact_from_list(list_id, {
      'emails' => [email],
    })
  rescue Brevo::ApiError => e
    puts "Exception when calling ContactsApi->update_contact: #{e} #{e.response_body}"
  end

  def self.update_contact email, attributes
    return if Rails.env.development?
    
    client = Brevo::ContactsApi.new
    attributes.deep_transform_keys! { |key| key.to_s.upcase }

    # Update a contact
    p client.update_contact(CGI.escape(email), 'attributes' => attributes)
  rescue Brevo::ApiError => e
    puts "Exception when calling ContactsApi->update_contact: #{e} #{e.response_body}"
  end

  def self.send_email template, config
    puts "[Brevo] Send #{template}"
    if Rails.env.development?
      puts config.to_json
      #return
    end
    
    config.reverse_merge!({
      templateId: BrevoAPI::TEMPLATES[template],
      params: {},
      tags: [],
    })

    config[:bcc] = [{ name: "Sahaj Atlas", email: "contact@sydevelopers.com" }] unless %i[confirmation reminder].include?(template)

    config[:tags] << 'atlas'
    config[:tags] << template.to_s

    config[:params][:text] ||= {}
    config[:params][:text].reverse_merge!(I18n.translate('emails.common'))

    client = Brevo::TransactionalEmailsApi.new
    p client.send_transac_email(config)
  rescue Brevo::ApiError => e
    puts "Exception when calling TransactionalEmailsApi->send_transac_email: #{e} #{e.response_body}"
  end

end
