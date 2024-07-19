class UpgradePasswordless < ActiveRecord::Migration[7.0]
  def change
    Passwordless::Session.delete_all

    # Encrypted tokens
    add_column(:passwordless_sessions, :token_digest, :string)
    add_index(:passwordless_sessions, :token_digest)
    remove_column(:passwordless_sessions, :token, :string, null: false)
    
    # UUID
    add_column(:passwordless_sessions, :identifier, :string)
    add_index(:passwordless_sessions, :identifier, unique: true)

    # Remove PII
    remove_column(:passwordless_sessions, :user_agent, :string, null: false)
    remove_column(:passwordless_sessions, :remote_addr, :string, null: false)

    Passwordless::Session.delete_all
  end
end