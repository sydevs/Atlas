class MakeClientDomainNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :clients, :domain, true
    change_column_default :clients, :domain, from: "", to: nil
  end
end
