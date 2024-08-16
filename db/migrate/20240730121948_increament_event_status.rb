class IncreamentEventStatus < ActiveRecord::Migration[7.0]
  def up
    Event.where('status > 2').update_all("status = status + 1")
  end
  def down
    Event.where('status > 3').update_all("status = status - 1")
  end
end
