namespace :mail do
  desc 'Send list of recent registrations to every program manager'
  task registrations: :environment do
    Event.with_new_registrations.where('registrations_sent_at > ?', 3.days.ago).in_batches.each_record do |event|
      event.managers.in_batches.each_record do |manager|
        ManagerMailer.with(manager: manager, event: event).registrations.deliver_now
      end
    end
  end

  desc 'Send a verification email to the managers of out-of-date events'
  task verifications: :environment do
    Event.needs_review.in_batches.each_record do |event|
      managers = event.needs_review?(:urgent) ? event.venue.parent_managers : event.managers
      managers.in_batches.each_record do |manager|
        ManagerMailer.with(manager: manager, event: event).verification.deliver_now
      end
    end
  end

  desc 'Send a verification email to the managers of out-of-date events'
  task expirations: :environment do
    Event.recently_expired.in_batches.each_record do |event|
      event.managers.in_batches.each_record do |manager|
        ManagerMailer.with(manager: manager, event: event).expired.deliver_now
      end

      event.venue.parent_managers.in_batches.each_record do |manager|
        ManagerMailer.with(manager: manager, event: event).expired.deliver_now
      end
    end
  end

  desc 'Send a summary email to the managers of every region'
  task summaries: :environment do
    Country.in_batches.each_record do |country|
      country.managers.in_batches.each_record do |manager|
        SummaryMailer.with(manager: manager, region: country).regional.deliver_now
      end
    end

    Province.in_batches.each_record do |province|
      province.managers.in_batches.each_record do |manager|
        SummaryMailer.with(manager: manager, region: province).regional.deliver_now
      end
    end

    LocalArea.in_batches.each_record do |local_area|
      local_area.managers.in_batches.each_record do |manager|
        SummaryMailer.with(manager: manager, region: local_area).regional.deliver_now
      end
    end

    Manager.administrators.in_batches.each_record do |manager|
      SummaryMailer.with(manager: manager).global.deliver_now
    end
  end

  namespace :test do
    desc 'Generates one of each email type for testing purposes'
    task all: :environment do
      %w[
        welcome registrations verification escalation
        expired expired_escalation
        confirmation
      ].each_with_index do |test, index|
        puts "Press enter to proceed to the next test (mail:#{test})" unless index == 0
        STDIN.gets unless index == 0
        puts "Testing: mail:#{test}"
        Rake::Task["mail:test:#{test}"].invoke
      end
    end

    desc 'Generates an email welcoming a manager who has been newly assigned to an event'
    task welcome: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:managers).reorder('RANDOM()').first
      manager = event.managers.first
      puts "Sending mail to #{manager.name} for #{event.name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).welcome.deliver_now
    end

    desc 'Sends list of recent registrations to one program manager'
    task registrations: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:managers, :registrations).reorder('RANDOM()').first
      event.registrations_sent_at = event.created_at
      manager = event.managers.first
      puts "Sending mail to #{manager.name} for #{event.name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).registrations.deliver_now
    end

    desc 'Sends a verification email to one of the managers of one out-of-date event'
    task verification: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:managers).reorder('RANDOM()').first
      manager = event.managers.first
      puts "Sending mail to #{manager.name} for #{event.name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).verification.deliver_now
    end

    desc 'Sends a verification email to one of the super managers of one out-of-date event'
    task escalation: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:managers).reorder('RANDOM()').first
      manager = event.parent_managers.first
      puts "Sending mail to #{manager.name} for #{event.name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).escalation.deliver_now
    end

    desc 'Sends a verification email to one of the managers of one expired event'
    task expired: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:managers).reorder('RANDOM()').first
      manager = event.managers.first
      puts "Sending mail to #{manager.name} for #{event.name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).expired.deliver_now
    end

    desc 'Sends a verification email to one of the super managers of one expired event'
    task expired_escalation: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:managers).reorder('RANDOM()').first
      manager = event.parent_managers.last
      puts "Sending mail to #{manager.name} for #{event.name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).expired.deliver_now
    end

    desc 'Sends a summary email to one regional manager'
    task regional_summary: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      country = Country.joins(:managers).reorder('RANDOM()').first
      manager = country.managers.first
      puts "Sending mail to #{manager.name} for #{CountryDecorator.get_label(country.country_code)}"
      SummaryMailer.with(manager: manager, region: country, test: true).regional.deliver_now
    end

    desc 'Sends a summary email to one global administrator'
    task global_summary: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      manager = Manager.administrators.reorder('RANDOM()').first
      puts "Sending mail to #{manager.name}"
      SummaryMailer.with(manager: manager, test: true).global.deliver_now
    end

    desc 'Sends a confirmation email to one registration'
    task confirmation: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      registration = Registration.joins(:event).where.not(events: { description: nil }).first
      puts "Sending mail to #{registration.name} for #{registration.event.name || registration.event.venue.street}"
      RegistrationMailer.with(registration: registration, test: true).confirmation.deliver_now
    end
  end
end
