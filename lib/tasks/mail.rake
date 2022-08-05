namespace :mail do
  desc 'Send list of recent registrations to every program manager'
  task all: :environment do
    %w[events summaries].each do |key|
      puts "[MAIL] Run task mail:#{key}"
      Rake::Task["mail:#{key}"].invoke
    end

    Rake::Task['mail:cleanup'].invoke
  end

  task cleanup: :environment do
    Passwordless::Session.where("expires_at < ?", 1.day.ago).delete_all
  end

  desc 'Send event reminder emails.'
  task events: :environment do
    events = Event.publicly_visible.ready_for_reminder_email.joins(:manager).includes(:registrations)
    puts "[MAIL] Attempting to send reminder emails for #{events.count} events"
    events.in_batches.each_record do |event|
      EventMailer.with(event: event, manager: event.manager).reminder.deliver_later
    end
  end

  desc 'Send summary emails.'
  task summaries: :environment do
    [Country, Region, Area].each do |model|
      records = model.active_since(6.months.ago).ready_for_summary_email.includes(:managers)
      puts "[MAIL] Attempting to send summary emails for #{records.count} #{model.model_name.plural.downcase}"
      mailer = model == Country ? CountryMailer : PlaceMailer
      records.in_batches.each_record do |record|
        record.managers.each do |manager|
          mailer.with(record: record, manager: manager).summary.deliver_later
        end
      end
    end
    
    Manager.administrators.each do |manager|
      ApplicationMailer.with(manager: manager).summary.deliver_later
    end
  end
end
