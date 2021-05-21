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

  desc 'Send event emails.'
  task events: :environment do
    status_events = Event.not_archived.ready_for_status_email.joins(:manager)
    puts "[MAIL] Attempting to send status emails for #{status_events.count} events"
    status_events.in_batches.each_record do |event|
      EventMailer.with(event: event).status.deliver_now
    end
    
    reminder_events = Event.publicly_visible.ready_for_reminder_email.joins(:manager, :registrations)
    puts "[MAIL] Attempting to send reminder emails for #{reminder_events.count} events"
    reminder_events.in_batches.each_record do |event|
      EventMailer.with(event: event).reminder.deliver_now
    end
  end

  desc 'Send summary emails.'
  task summaries: :environment do
    [Country, Province, LocalArea].each do |model|
      records = model.active_since(6.months.ago).ready_for_summary_email.joins(:managers)
      puts "[MAIL] Attempting to send summary emails for #{records.count} #{model.model_name.plural.downcase}"
      mailer = model == Country ? CountryMailer : RegionMailer
      records.in_batches.each_record do |record|
        mailer.with(record: record).summary.deliver_now
      end
    end
    
    ApplicationMailer.summary.deliver_now
  end

  namespace :test do
    desc 'Generates one of each email type for testing purposes'
    task all: :environment do
      %w[
        managers:welcome
        application:summary
        countries:summary provinces:summary local_areas:summary
        events:status events:reminder
        managed_records:created managed_records:event_manager_changed
      ].each_with_index do |test, index|
        # puts "Press enter to proceed to the next test (mail:#{test})" unless index.zero?
        # STDIN.gets unless index.zero?
        puts "Testing: mail:#{test}"
        Rake::Task["mail:test:#{test}"].invoke
      end
    end

    namespace :application do
      desc 'Sends summary for one country'
      task summary: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        ApplicationMailer.with(test: true).summary.deliver_now
      end
    end

    namespace :managers do
      desc 'Sends welcome to one manager'
      task welcome: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        manager = Manager.reorder('RANDOM()').first
        ManagerMailer.with(manager: manager, test: true).welcome.deliver_now
      end
    end

    namespace :countries do
      desc 'Sends summary for one country'
      task :summary, [:id] => :environment do |_, args|
        ActionMailer::Base.delivery_method = :letter_opener
        country = args.id ? Country.find(args.id) : Country.joins(:managers).reorder('RANDOM()').first
        CountryMailer.with(country: country, test: true).summary.deliver_now
      end
    end

    namespace :provinces do
      desc 'Sends summary for one province'
      task :summary, [:id] => :environment do |_, args|
        ActionMailer::Base.delivery_method = :letter_opener
        province = args.id ? Province.find(args.id) : Province.joins(:managers).reorder('RANDOM()').first
        RegionMailer.with(region: province, test: true).summary.deliver_now
      end
    end

    namespace :local_areas do
      desc 'Sends summary for one local area'
      task :summary, [:id] => :environment do |_, args|
        ActionMailer::Base.delivery_method = :letter_opener
        local_area = args.id ? LocalArea.find(args.id) : LocalArea.joins(:managers).reorder('RANDOM()').first
        RegionMailer.with(region: local_area, test: true).summary.deliver_now
      end
    end

    namespace :events do
      desc 'Sends status for one event'
      task status: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        event = Event.joins(:manager, :registrations).reorder('RANDOM()').first
        EventMailer.with(event: event, test: true).status.deliver_now
      end
  
      desc 'Sends reminder for one event'
      task reminder: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        event = Event.not_finished.joins(:manager, :registrations).reorder('RANDOM()').first
        EventMailer.with(event: event, test: true).reminder.deliver_now
      end
    end

    namespace :managed_records do
      desc 'Sends status for one event'
      task created: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        record = ManagedRecord.joins(:manager).reorder('RANDOM()').first
        ManagedRecordMailer.with(managed_record: record, test: true).created.deliver_now
      end
  
      desc 'Sends reminder for one event'
      task event_manager_changed: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        event = Event.not_finished.joins(:manager).reorder('RANDOM()').first
        ManagedRecordMailer.with(event: event, test: true).created.deliver_now
      end
    end
  end
end
