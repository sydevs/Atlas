
## SENDINBLUE
# This concern simplifies requests to sendinblue.com

module SendinblueAPI

  LISTS = {
    registrations: 13,
  }.freeze

  TEMPLATES = {
    confirmation: 9,
  }.freeze

  def self.subscribe email, list_id, attributes
    client = SibApiV3Sdk::ContactsApi.new

    # Create a contact
    p client.create_contact(
      'email' => email,
      'attributes' => attributes.deep_transform_keys { |key| key.to_s.upcase },
      'listIds' => [list_id.to_i],
      'updateEnabled' => true
    )
  rescue SibApiV3Sdk::ApiError => e
    puts "Exception when calling ContactsApi->create_contact: #{e} #{e.response_body}"
  end

  def self.send_email config
    client = SibApiV3Sdk::TransactionalEmailsApi.new
    p client.send_transac_email(config)
  rescue SibApiV3Sdk::ApiError => e
    puts "Exception when calling TransactionalEmailsApi->send_transac_email: #{e} #{e.response_body}"
  end

end
