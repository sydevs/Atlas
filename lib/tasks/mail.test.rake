namespace :mail do
  namespace :test do
    desc 'Generates one of each email type for testing purposes'
    task all: :environment do
      %w[
        managers:welcome
        application:summary
        countries:summary regions:summary areas:summary
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
        manager = Manager.administrators.reorder('RANDOM()').first
        ApplicationMailer.with(manager: manager, test: true).summary.deliver_now
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
        manager = country.managers.reorder('RANDOM()').first
        CountryMailer.with(country: country, manager: manager, test: true).summary.deliver_now
      end
    end

    namespace :regions do
      desc 'Sends summary for one region'
      task :summary, [:id] => :environment do |_, args|
        ActionMailer::Base.delivery_method = :letter_opener
        region = args.id ? Region.find(args.id) : Region.joins(:managers).reorder('RANDOM()').first
        manager = region.managers.reorder('RANDOM()').first
        PlaceMailer.with(place: region, manager: manager, test: true).summary.deliver_now
      end
    end

    namespace :areas do
      desc 'Sends summary for one local area'
      task :summary, [:id] => :environment do |_, args|
        ActionMailer::Base.delivery_method = :letter_opener
        area = args.id ? Area.find(args.id) : Area.joins(:managers).reorder('RANDOM()').first
        manager = area.managers.reorder('RANDOM()').first
        PlaceMailer.with(place: area, manager: manager, test: true).summary.deliver_now
      end
    end

    namespace :events do
      desc 'Sends status for one event'
      task :status, [:status] => :environment do |_, args|
        ActionMailer::Base.delivery_method = :letter_opener
        if args.status
          event = Event.where(status: args.status).joins(:manager, :registrations).reorder('RANDOM()').first
        else
          event = Event.joins(:manager, :registrations).reorder('RANDOM()').first
        end

        EventMailer.with(event: event, test: true).status.deliver_now if event
      end
  
      desc 'Sends reminder for one event'
      task reminder: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        event = Event.where.not(status: :finished).joins(:manager, :registrations).reorder('RANDOM()').first
        EventMailer.with(event: event, test: true).reminder.deliver_now
      end
    end

    namespace :managed_records do
      desc 'Sends notification for a manager change'
      task created: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        record = ManagedRecord.joins(:manager).reorder('RANDOM()').first
        ManagedRecordMailer.with(managed_record: record, test: true).created.deliver_now
      end
  
      desc 'Sends notification for a client manager change'
      task client_manager_changed: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        client = Client.joins(:manager).reorder('RANDOM()').first
        ManagedRecordMailer.with(record: client, test: true).created.deliver_now
      end
  
      desc 'Sends notification for an event manager change'
      task event_manager_changed: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        event = Event.where.not(status: :finished).joins(:manager).reorder('RANDOM()').first
        ManagedRecordMailer.with(record: event, test: true).created.deliver_now
      end
    end
  end
end
