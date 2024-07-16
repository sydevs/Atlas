Rails.application.config.to_prepare do
  ActiveRecord::Base.extend(Searchable::ActiveRecord)
end
