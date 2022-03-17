class MakeClientDomainNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :clients, :domain, true
    change_column_default :clients, :domain, nil
  end
end
