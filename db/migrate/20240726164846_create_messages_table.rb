# typed: ignore
class CreateMessagesTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :messages do |t|
      t.string :brevo_id
      t.string :topic
      t.text :body
      t.references :channel, :polymorphic => true, :type => :bigint
      t.references :received_messageable, :polymorphic => true, :type => :bigint
      t.references :sent_messageable, :polymorphic => true, :type => :bigint
      t.boolean :opened, :default => false
      t.boolean :recipient_delete, :default => false
      t.boolean :sender_delete, :default => false
      t.timestamps

      # ancestry
      t.string :ancestry
    end

    add_index :messages, [:sent_messageable_id, :received_messageable_id], :name => "acts_as_messageable_ids"
    add_index :messages, :ancestry
  end

  def self.down
    drop_table :messages
  end
end
