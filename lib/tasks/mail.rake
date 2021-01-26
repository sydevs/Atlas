namespace :mail do
  desc 'Send list of recent registrations to every program manager'
  task all: :environment do
    %w[registrations expirations verifications].each do |key|
      puts "[MAIL] Run task mail:#{key}"
      Rake::Task["mail:#{key}"].invoke
    end
  end

  desc 'Send list of recent registrations to every program manager'
  task registrations: :environment do
    since = 1.day.ago

    Event.notifications_enabled.with_new_registrations.no_recent_email_sent(:last_registration_email_sent_at).in_batches.each_record do |event|
      ManagerMailer.with(manager: event.manager, event: event).registrations.deliver_now
      event.update_column :last_registration_email_sent_at, Time.now
    end
  end

  desc 'Send a verification email to the managers of out-of-date events'
  task verifications: :environment do
    since = Expirable.date_for(:interval)

    Event.needs_review.no_recent_email_sent(:last_expiration_email_sent_at).in_batches.each_record do |event|
      puts "Event needs review: #{event}"
      if event.needs_review?(:urgent)
        event.venue.all_managers.each do |manager|
          ManagerMailer.with(manager: manager, event: event).verification.deliver_now
        end
      else
        ManagerMailer.with(manager: event.manager, event: event).verification.deliver_now
      end

      event.update_column :last_expiration_email_sent_at, Time.now
    end
  end

  desc 'Send a verification email to the managers of out-of-date events'
  task expirations: :environment do
    since = Expirable.date_for(:interval)

    Event.recently_expired.no_recent_email_sent(:last_expiration_email_sent_at).in_batches.each_record do |event|
      ManagerMailer.with(manager: event.manager, event: event).expired.deliver_now

      event.venue.all_managers.each do |manager|
        ManagerMailer.with(manager: manager, event: event).expired.deliver_now
      end

      event.update_column :last_expiration_email_sent_at, Time.now
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
        welcome:event welcome:worldwide
        registrations verification escalation
        expired expired_escalation
      ].each_with_index do |test, index|
        puts "Press enter to proceed to the next test (mail:#{test})" unless index.zero?
        STDIN.gets unless index.zero?
        puts "Testing: mail:#{test}"
        Rake::Task["mail:test:#{test}"].invoke
      end
    end

    desc 'Sends list of recent registrations to one program manager'
    task registrations: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.notifications_enabled.joins(:manager, :registrations).reorder('RANDOM()').first
      event.last_registration_email_sent_at = event.created_at
      manager = event.manager
      puts "Sending mail to #{manager.name} for #{event.custom_name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).registrations.deliver_now
    end

    desc 'Sends a verification email to one of the managers of one out-of-date event'
    task verification: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:manager).reorder('RANDOM()').first
      manager = event.manager
      puts "Sending mail to #{manager.name} for #{event.custom_name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).verification.deliver_now
    end

    desc 'Sends a verification email to one of the super managers of one out-of-date event'
    task escalation: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.reorder('RANDOM()').first
      manager = event.venue.all_managers.first
      puts "Sending mail to #{manager.name} for #{event.custom_name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).escalation.deliver_now
    end

    desc 'Sends a verification email to one of the managers of one expired event'
    task expired: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:manager).reorder('RANDOM()').first
      manager = event.manager
      puts "Sending mail to #{manager.name} for #{event.custom_name || event.venue.street}"
      ManagerMailer.with(manager: manager, event: event, test: true).expired.deliver_now
    end

    desc 'Sends a verification email to one of the super managers of one expired event'
    task expired_escalation: :environment do
      ActionMailer::Base.delivery_method = :letter_opener
      event = Event.joins(:manager).reorder('RANDOM()').first
      manager = event.venue.all_managers.last
      puts "Sending mail to #{manager.name} for #{event.custom_name || event.venue.street}"
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

    namespace :welcome do
      desc 'Generates one of each welcome email type for testing purposes'
      task all: :environment do
        %w[
          event venue local_area province country worldwide
        ].each_with_index do |test, index|
          puts "Press enter to proceed to the next test (mail:#{test})" unless index.zero?
          STDIN.gets unless index.zero?
          puts "Testing: mail:welcome:#{test}"
          Rake::Task["mail:test:welcome:#{test}"].invoke
        end
      end

      desc 'Generates an email welcoming a manager who has been newly assigned to an event'
      task event: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        event = Event.joins(:venue, :manager).reorder('RANDOM()').first
        manager = event.manager
        puts "Sending mail to #{manager.name} for #{event.custom_name || event.venue.street}"
        ManagerMailer.with(manager: manager, context: event, test: true).welcome.deliver_now
      end

      desc 'Generates an email welcoming a manager who has been newly assigned to a venue'
      task venue: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        venue = Venue.joins(:managers).reorder('RANDOM()').first
        manager = venue.managers.first
        puts "Sending mail to #{manager.name} for #{venue.name || venue.street}"
        ManagerMailer.with(manager: manager, context: venue, test: true).welcome.deliver_now
      end

      desc 'Generates an email welcoming a manager who has been newly assigned to a local area'
      task local_area: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        local_area = LocalArea.joins(:managers).reorder('RANDOM()').first
        manager = local_area.managers.first
        puts "Sending mail to #{manager.name} for #{local_area.name}"
        ManagerMailer.with(manager: manager, context: local_area, test: true).welcome.deliver_now
      end

      desc 'Generates an email welcoming a manager who has been newly assigned to a province'
      task province: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        province = Province.joins(:managers).reorder('RANDOM()').first
        manager = province.managers.first
        puts "Sending mail to #{manager.name} for #{ProvinceDecorator.get_name(province.province_code, province.country_code)}"
        ManagerMailer.with(manager: manager, context: province, test: true).welcome.deliver_now
      end

      desc 'Generates an email welcoming a manager who has been newly assigned to a country'
      task country: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        country = Country.joins(:managers).reorder('RANDOM()').first
        manager = country.managers.first
        puts "Sending mail to #{manager.name} for #{CountryDecorator.get_label(country.country_code)}"
        ManagerMailer.with(manager: manager, context: country, test: true).welcome.deliver_now
      end

      desc 'Generates an email welcoming an administrator'
      task worldwide: :environment do
        ActionMailer::Base.delivery_method = :letter_opener
        country = Country.joins(:managers).reorder('RANDOM()').first
        manager = Manager.administrators.first
        puts "Sending mail to #{manager.name} as an administrator"
        ManagerMailer.with(manager: manager, test: true).welcome.deliver_now
      end
    end
  end
end
