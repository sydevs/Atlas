
## SENDINBLUE
# This concern simplifies requests to sendinblue.com

module Sendinblue

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
    puts "Exception when calling ContactsApi->create_contact: #{e}"
  end

end
