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

    parent.managed_by?(manager)
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
        self.manager.update_sendinblue! update_management: true
      else
        self.manager_id = nil
        existing_manager.update_sendinblue! update_management: true
      end
    end

    def find_or_create_manager
      return unless manager&.email.present?

      old_manager = manager
      self.new_manager_record = false
      default_language_code = try(:language_code) || try(:locale) || I18n.locale

      self.manager = Manager.find_or_create_by(email: manager.email.downcase) do |new_manager|
        new_manager.name = manager.name
        new_manager.locale = default_language_code
        self.new_manager_record = true
      end

      self.manager.update_sendinblue! update_management: true
      old_manager.update_sendinblue! update_management: true
      self.manager.update_column(:language_code, default_language_code) if self.manager.language_code.nil?
    end

end
