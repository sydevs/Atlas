class AddRefreshTokenToClient < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :wix_refresh_token, :string
  end
end
