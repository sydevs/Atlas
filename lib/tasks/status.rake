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
      Event.find(args.id).reset_status!
    else
      events = Event.all
      puts "Resetting #{events.count} event statuses"
      events.in_batches.each_record(&:reset_status!)
    end
  end
end