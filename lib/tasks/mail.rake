
namespace :mail do
  desc "Send list of recent registrations to every program manager"
  task :registrations => :environment do
    Events.in_batches.each_record do |event|
      event.managers.in_batches.each_record do |manager|
        ManagerMailer.with(manager: manager, event: event, since: 1.year.ago).registrations.deliver_now
      end
    end    
  end

  desc "Send a verification email to the managers of out-of-date events"
  task :verification => :environment do
    Event.needs_review.in_batches.each_record do |event|
      managers = []

      if event.needs_review?(:urgent)
        managers = event.venue.parent.managers
      else
        managers = event.managers
      end

      managers.in_batches.each_record do |manager|
        ManagerMailer.with(manager: manager, event: event).verification.deliver_now
      end
    end    
  end

  namespace :test do
    desc "Send list of recent registrations to one program manager"
    task :registrations => :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.first
      manager = event.managers.first
      puts "Sending mail to #{manager.label} for #{event.label}"
      ManagerMailer.with(manager: manager, event: event, since: 1.year.ago).registrations.deliver_now
    end

    desc "Send a verification email to the mannagers of one out-of-date event"
    task :verification => :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.first
      manager = event.managers.first
      puts "Sending mail to #{manager.label} for #{event.label}"
      ManagerMailer.with(manager: manager, event: event).verification.deliver_now
    end

    desc "Send a verification email to the mannagers of one out-of-date event"
    task :welcome => :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.first
      manager = event.managers.first
      puts "Sending mail to #{manager.label} for #{event.label}"
      ManagerMailer.with(manager: manager, event: event).welcome.deliver_now
    end
  end
end
