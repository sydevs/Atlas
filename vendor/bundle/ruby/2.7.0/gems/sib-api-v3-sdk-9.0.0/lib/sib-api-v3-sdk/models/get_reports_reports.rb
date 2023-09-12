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
  class GetReportsReports
    # Date of the statistics
    attr_accessor :date

    # Number of requests for the date
    attr_accessor :requests

    # Number of delivered emails for the date
    attr_accessor :delivered

    # Number of hardbounces for the date
    attr_accessor :hard_bounces

    # Number of softbounces for the date
    attr_accessor :soft_bounces

    # Number of clicks for the date
    attr_accessor :clicks

    # Number of unique clicks for the date
    attr_accessor :unique_clicks

    # Number of openings for the date
    attr_accessor :opens

    # Number of unique openings for the date
    attr_accessor :unique_opens

    # Number of complaints (spam reports) for the date
    attr_accessor :spam_reports

    # Number of blocked emails for the date
    attr_accessor :blocked

    # Number of invalid emails for the date
    attr_accessor :invalid

    # Number of unsubscribed emails for the date
    attr_accessor :unsubscribed

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'date' => :'date',
        :'requests' => :'requests',
        :'delivered' => :'delivered',
        :'hard_bounces' => :'hardBounces',
        :'soft_bounces' => :'softBounces',
        :'clicks' => :'clicks',
        :'unique_clicks' => :'uniqueClicks',
        :'opens' => :'opens',
        :'unique_opens' => :'uniqueOpens',
        :'spam_reports' => :'spamReports',
        :'blocked' => :'blocked',
        :'invalid' => :'invalid',
        :'unsubscribed' => :'unsubscribed'
      }
    end

    # Attribute type mapping.
    def self.swagger_types
      {
        :'date' => :'Date',
        :'requests' => :'Integer',
        :'delivered' => :'Integer',
        :'hard_bounces' => :'Integer',
        :'soft_bounces' => :'Integer',
        :'clicks' => :'Integer',
        :'unique_clicks' => :'Integer',
        :'opens' => :'Integer',
        :'unique_opens' => :'Integer',
        :'spam_reports' => :'Integer',
        :'blocked' => :'Integer',
        :'invalid' => :'Integer',
        :'unsubscribed' => :'Integer'
      }
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      return unless attributes.is_a?(Hash)

      # convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }

      if attributes.has_key?(:'date')
        self.date = attributes[:'date']
      end

      if attributes.has_key?(:'requests')
        self.requests = attributes[:'requests']
      end

      if attributes.has_key?(:'delivered')
        self.delivered = attributes[:'delivered']
      end

      if attributes.has_key?(:'hardBounces')
        self.hard_bounces = attributes[:'hardBounces']
      end

      if attributes.has_key?(:'softBounces')
        self.soft_bounces = attributes[:'softBounces']
      end

      if attributes.has_key?(:'clicks')
        self.clicks = attributes[:'clicks']
      end

      if attributes.has_key?(:'uniqueClicks')
        self.unique_clicks = attributes[:'uniqueClicks']
      end

      if attributes.has_key?(:'opens')
        self.opens = attributes[:'opens']
      end

      if attributes.has_key?(:'uniqueOpens')
        self.unique_opens = attributes[:'uniqueOpens']
      end

      if attributes.has_key?(:'spamReports')
        self.spam_reports = attributes[:'spamReports']
      end

      if attributes.has_key?(:'blocked')
        self.blocked = attributes[:'blocked']
      end

      if attributes.has_key?(:'invalid')
        self.invalid = attributes[:'invalid']
      end

      if attributes.has_key?(:'unsubscribed')
        self.unsubscribed = attributes[:'unsubscribed']
      end
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      invalid_properties = Array.new
      if @date.nil?
        invalid_properties.push('invalid value for "date", date cannot be nil.')
      end

      if @requests.nil?
        invalid_properties.push('invalid value for "requests", requests cannot be nil.')
      end

      if @delivered.nil?
        invalid_properties.push('invalid value for "delivered", delivered cannot be nil.')
      end

      if @hard_bounces.nil?
        invalid_properties.push('invalid value for "hard_bounces", hard_bounces cannot be nil.')
      end

      if @soft_bounces.nil?
        invalid_properties.push('invalid value for "soft_bounces", soft_bounces cannot be nil.')
      end

      if @clicks.nil?
        invalid_properties.push('invalid value for "clicks", clicks cannot be nil.')
      end

      if @unique_clicks.nil?
        invalid_properties.push('invalid value for "unique_clicks", unique_clicks cannot be nil.')
      end

      if @opens.nil?
        invalid_properties.push('invalid value for "opens", opens cannot be nil.')
      end

      if @unique_opens.nil?
        invalid_properties.push('invalid value for "unique_opens", unique_opens cannot be nil.')
      end

      if @spam_reports.nil?
        invalid_properties.push('invalid value for "spam_reports", spam_reports cannot be nil.')
      end

      if @blocked.nil?
        invalid_properties.push('invalid value for "blocked", blocked cannot be nil.')
      end

      if @invalid.nil?
        invalid_properties.push('invalid value for "invalid", invalid cannot be nil.')
      end

      if @unsubscribed.nil?
        invalid_properties.push('invalid value for "unsubscribed", unsubscribed cannot be nil.')
      end

      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      return false if @date.nil?
      return false if @requests.nil?
      return false if @delivered.nil?
      return false if @hard_bounces.nil?
      return false if @soft_bounces.nil?
      return false if @clicks.nil?
      return false if @unique_clicks.nil?
      return false if @opens.nil?
      return false if @unique_opens.nil?
      return false if @spam_reports.nil?
      return false if @blocked.nil?
      return false if @invalid.nil?
      return false if @unsubscribed.nil?
      true
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
          date == o.date &&
          requests == o.requests &&
          delivered == o.delivered &&
          hard_bounces == o.hard_bounces &&
          soft_bounces == o.soft_bounces &&
          clicks == o.clicks &&
          unique_clicks == o.unique_clicks &&
          opens == o.opens &&
          unique_opens == o.unique_opens &&
          spam_reports == o.spam_reports &&
          blocked == o.blocked &&
          invalid == o.invalid &&
          unsubscribed == o.unsubscribed
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Fixnum] Hash code
    def hash
      [date, requests, delivered, hard_bounces, soft_bounces, clicks, unique_clicks, opens, unique_opens, spam_reports, blocked, invalid, unsubscribed].hash
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
