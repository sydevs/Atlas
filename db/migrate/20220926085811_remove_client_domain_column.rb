class RemoveClientDomainColumn < ActiveRecord::Migration[6.1]
  def change
    Client.in_batches.each_record do |client|
      client.config ||= {}
      client.config['domain'] = client[:domain]
      client.save! validate: false
    end

    remove_column :clients, :domain, :string
  end
end
