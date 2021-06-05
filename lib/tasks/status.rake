namespace :status do
  desc 'Update the status of all expirable items'
  task :update, [:id] => :environment do |_, args|
    if args.id
      Event.find(args.id).update_status!
    else
      events = Event.where('should_update_status_at <= ?', Time.now)
      puts "Updating #{events.count} event statuses"
      events.in_batches.each_record(&:update_status!)
    end
  end  

  desc 'Reset the status of all expirable items'
  task :reset, [:id] => :environment do |_, args|
    if args.id
      event = Event.find(args.id)
      puts "Resetting event ##{event.id}"
      event.reset_status!
      event.update_column :expired_at, Time.now if event.expired_at.nil? && event.archived?
    else
      events = Event.all
      puts "Resetting #{events.count} event statuses"
      events.in_batches.each_record do |event|
        event.reset_status!
        event.update_column :expired_at, Time.now if event.expired_at.nil? && event.archived?
      end
    end
  end
end