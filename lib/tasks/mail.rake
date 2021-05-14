namespace :mail do
  desc 'Send list of recent registrations to every program manager'
  task all: :environment do
    %w[events].each do |key|
      puts "[MAIL] Run task mail:#{key}"
      Rake::Task["mail:#{key}"].invoke
    end

    Rake::Task['mail:cleanup'].invoke
  end

  task cleanup: :environment do
    Passwordless::Session.where("expires_at < ?", 1.day.ago).delete_all
  end

  desc 'Send event status to each event manager.'
  task events: :environment do
    events = Event.publicly_visible.no_recent_email_sent
    puts "[MAIL] Attempting to send emails for #{events.count} events"

    events.in_batches.each_record do |event|
      EventMailer.with(event: event).status.deliver_now
    end
  end

  namespace :test do
    desc 'Generates one of each email type for testing purposes'
    task all: :environment do
      %w[
        events:status events:reminder
      ].each_with_index do |test, index|
        puts "Press enter to proceed to the next test (mail:#{test})" unless index.zero?
        STDIN.gets unless index.zero?
        puts "Testing: mail:#{test}"
        Rake::Task["mail:test:#{test}"].invoke
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
        event = Event.joins(:manager, :registrations).reorder('RANDOM()').first
        EventMailer.with(event: event, test: true).reminder.deliver_now
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
  end
end
