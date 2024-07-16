Rails.application.config.to_prepare do
  Audited.config do |config|
    config.audit_class = Audit
    config.max_audits = 50
  end
end
