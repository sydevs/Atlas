class UpdateEmailTimestampsAndMeta < ActiveRecord::Migration[6.1]
  def change
    remove_column :managers, :summary_email_sent_at, :datetime
    remove_column :events, :summary_email_sent_at, :datetime
    remove_column :events, :reminder_email_sent_at, :datetime

    add_column :events, :status_email_sent_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :events, :reminder_email_sent_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    
    %i[countries provinces local_areas].each do |table|
      add_column table, :summary_email_sent_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      add_column table, :summary_metadata, :jsonb, default: '{}'
    end
  end
end
