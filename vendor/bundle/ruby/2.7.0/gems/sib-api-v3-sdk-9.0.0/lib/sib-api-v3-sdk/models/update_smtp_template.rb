=begin
#SendinBlue API

#SendinBlue provide a RESTFul API that can be used with any languages. With this API, you will be able to :   - Manage your campaigns and get the statistics   - Manage your contacts   - Send transactional Emails and SMS   - and much more...  You can download our wrappers at https://github.com/orgs/sendinblue  **Possible responses**   | Code | Message |   | :-------------: | ------------- |   | 200  | OK. Successful Request  |   | 201  | OK. Successful Creation |   | 202  | OK. Request accepted |   | 204  | OK. Successful Update/Deletion  |   | 400  | Error. Bad Request  |   | 401  | Error. Authentication Needed  |   | 402  | Error. Not enough credit, plan upgrade needed  |   | 403  | Error. Permission denied  |   | 404  | Error. Object does not exist |   | 405  | Error. Method not allowed  |   | 406  | Error. Not Acceptable  | 

OpenAPI spec version: 3.0.0
Contact: contact@sendinblue.com
Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 2.4.19

=end

require 'date'

module SibApiV3Sdk
  class UpdateSmtpTemplate
    # Tag of the template
    attr_accessor :tag

    attr_accessor :sender

    # Name of the template
    attr_accessor :template_name

    # Required if htmlUrl is empty. If the template is designed using Drag & Drop editor via HTML content, then the design page will not have Drag & Drop editor access for that template. Body of the message (HTML must have more than 10 characters)
    attr_accessor :html_content

    # Required if htmlContent is empty. URL to the body of the email (HTML)
    attr_accessor :html_url

    # Subject of the email
    attr_accessor :subject

    # Email on which campaign recipients will be able to reply to
    attr_accessor :reply_to

    # To personalize the «To» Field. If you want to include the first name and last name of your recipient, add {FNAME} {LNAME}. These contact attributes must already exist in your SendinBlue account. If input parameter 'params' used please use {{contact.FNAME}} {{contact.LNAME}} for personalization
    attr_accessor :to_field

    # Absolute url of the attachment (no local file). Extension allowed: xlsx, xls, ods, docx, docm, doc, csv, pdf, txt, gif, jpg, jpeg, png, tif, tiff, rtf, bmp, cgm, css, shtml, html, htm, zip, xml, ppt, pptx, tar, ez, ics, mobi, msg, pub and eps
    attr_accessor :attachment_url

    # Status of the template. isActive = false means template is inactive, isActive = true means template is active
    attr_accessor :is_active

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'tag' => :'tag',
        :'sender' => :'sender',
        :'template_name' => :'templateName',
        :'html_content' => :'htmlContent',
        :'html_url' => :'htmlUrl',
        :'subject' => :'subject',
        :'reply_to' => :'replyTo',
        :'to_field' => :'toField',
        :'attachment_url' => :'attachmentUrl',
        :'is_active' => :'isActive'
      }
    end

    # Attribute type mapping.
    def self.swagger_types
      {
        :'tag' => :'String',
        :'sender' => :'UpdateSmtpTemplateSender',
        :'template_name' => :'String',
        :'html_content' => :'String',
        :'html_url' => :'String',
        :'subject' => :'String',
        :'reply_to' => :'String',
        :'to_field' => :'String',
        :'attachment_url' => :'String',
        :'is_active' => :'BOOLEAN'
      }
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      return unless attributes.is_a?(Hash)

      # convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }

      if attributes.has_key?(:'tag')
        self.tag = attributes[:'tag']
      end

      if attributes.has_key?(:'sender')
        self.sender = attributes[:'sender']
      end

      if attributes.has_key?(:'templateName')
        self.template_name = attributes[:'templateName']
      end

      if attributes.has_key?(:'htmlContent')
        self.html_content = attributes[:'htmlContent']
      end

      if attributes.has_key?(:'htmlUrl')
        self.html_url = attributes[:'htmlUrl']
      end

      if attributes.has_key?(:'subject')
        self.subject = attributes[:'subject']
      end

      if attributes.has_key?(:'replyTo')
        self.reply_to = attributes[:'replyTo']
      end

      if attributes.has_key?(:'toField')
        self.to_field = attributes[:'toField']
      end

      if attributes.has_key?(:'attachmentUrl')
        self.attachment_url = attributes[:'attachmentUrl']
      end

      if attributes.has_key?(:'isActive')
        self.is_active = attributes[:'isActive']
      end
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      invalid_properties = Array.new
      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      true
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
          tag == o.tag &&
          sender == o.sender &&
          template_name == o.template_name &&
          html_content == o.html_content &&
          html_url == o.html_url &&
          subject == o.subject &&
          reply_to == o.reply_to &&
          to_field == o.to_field &&
          attachment_url == o.attachment_url &&
          is_active == o.is_active
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Fixnum] Hash code
    def hash
      [tag, sender, template_name, html_content, html_url, subject, reply_to, to_field, attachment_url, is_active].hash
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def build_from_hash(attributes)
      return nil unless attributes.is_a?(Hash)
      self.class.swagger_types.each_pair do |key, type|
        if type =~ /\AArray<(.*)>/i
          # check to ensure the input is an array given that the attribute
          # is documented as an array but the input is not
          if attributes[self.class.attribute_map[key]].is_a?(Array)
            self.send("#{key}=", attributes[self.class.attribute_map[key]].map { |v| _deserialize($1, v) })
          end
        elsif !attributes[self.class.attribute_map[key]].nil?
          self.send("#{key}=", _deserialize(type, attributes[self.class.attribute_map[key]]))
        end # or else data not found in attributes(hash), not an issue as the data can be optional
      end

      self
    end

    # Deserializes the data based on type
    # @param string type Data type
    # @param string value Value to be deserialized
    # @return [Object] Deserialized data
    def _deserialize(type, value)
      case type.to_sym
      when :DateTime
        DateTime.parse(value)
      when :Date
        Date.parse(value)
      when :String
        value.to_s
      when :Integer
        value.to_i
      when :Float
        value.to_f
      when :BOOLEAN
        if value.to_s =~ /\A(true|t|yes|y|1)\z/i
          true
        else
          false
        end
      when :Object
        # generic object (usually a Hash), return directly
        value
      when /\AArray<(?<inner_type>.+)>\z/
        inner_type = Regexp.last_match[:inner_type]
        value.map { |v| _deserialize(inner_type, v) }
      when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
        k_type = Regexp.last_match[:k_type]
        v_type = Regexp.last_match[:v_type]
        {}.tap do |hash|
          value.each do |k, v|
            hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
          end
        end
      else # model
        temp_model = SibApiV3Sdk.const_get(type).new
        temp_model.build_from_hash(value)
      end
    end

    # Returns the string representation of the object
    # @return [String] String presentation of the object
    def to_s
      to_hash.to_s
    end

    # to_body is an alias to to_hash (backward compatibility)
    # @return [Hash] Returns the object in the form of hash
    def to_body
      to_hash
    end

    # Returns the object in the form of hash
    # @return [Hash] Returns the object in the form of hash
    def to_hash
      hash = {}
      self.class.attribute_map.each_pair do |attr, param|
        value = self.send(attr)
        next if value.nil?
        hash[param] = _to_hash(value)
      end
      hash
    end

    # Outputs non-array value in the form of hash
    # For object, use to_hash. Otherwise, just return the value
    # @param [Object] value Any valid value
    # @return [Hash] Returns the value in the form of hash
    def _to_hash(value)
      if value.is_a?(Array)
        value.compact.map { |v| _to_hash(v) }
      elsif value.is_a?(Hash)
        {}.tap do |hash|
          value.each { |k, v| hash[k] = _to_hash(v) }
        end
      elsif value.respond_to? :to_hash
        value.to_hash
      else
        value
      end
    end

  end
end
