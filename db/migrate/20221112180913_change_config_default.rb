class ChangeConfigDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :clients, :config, {}
  end
end
