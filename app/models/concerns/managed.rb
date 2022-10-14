module Managed

  extend ActiveSupport::Concern

  included do
    belongs_to :manager
    accepts_nested_attributes_for :manager

    before_validation :find_manager
    after_save :find_or_create_manager
    after_save :notify_new_manager

    attr_accessor :new_manager_record
  end

  def managed_by? manager, super_manager: nil
    return true if super_manager != true && self.manager == manager

    false
  end

  private

    def notify_new_manager
      return unless saved_change_to_attribute?(:manager_id)

      if self.new_manager_record
        ManagerMailer.with(manager: manager, context: self).welcome.deliver_later
      else
        ManagedRecordMailer.with(record: self).created.deliver_later
      end
    end

    def find_manager
      return unless manager&.email.present?

      existing_manager = Manager.where(email: manager.email.downcase).first

      if existing_manager
        self.manager = existing_manager
      else
        self.manager_id = nil
      end
    end

    def find_or_create_manager
      return unless manager&.email.present?

      self.new_manager_record = false
      default_language_code = try(:language_code) || try(:locale) || I18n.locale

      self.manager = Manager.find_or_create_by(email: manager.email.downcase) do |new_manager|
        new_manager.name = manager.name
        new_manager.locale = default_language_code
        self.new_manager_record = true
      end

      # if self.is_a?(Client)
      #   SendinblueAPI.subscribe(manager.email, :client_managers, {
      #     email: manager.email,
      #     firstname: manager.first_name,
      #     lastname: manager.last_name,
      #   })
      # end

      self.manager.update_column(:language_code, default_language_code) if self.manager.language_code.nil?
    end

end
