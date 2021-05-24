namespace :status do
  desc 'Update the status of all expirable items'
  task :update, [:id] => :environment do |_, args|
    if args.id
      Event.find(args.id).update_status!
    else
      events = Event.where('should_update_status_at <= ?', Time.now)
      puts "Updating #{events.count} events"
      events.in_batches.each_record(&:update_status!)
    end
  end  
end