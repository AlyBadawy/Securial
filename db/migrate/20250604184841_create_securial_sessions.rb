class CreateSecurialSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :securial_sessions, id: :string do |t|
      t.references :user, null: false, type: :string, foreign_key: { to_table: :securial_users }

      t.string :ip_address, null: false
      t.string :user_agent, null: false

      t.string :refresh_token, null: false
      t.integer :refresh_count, default: 0
      t.datetime :last_refreshed_at
      t.datetime :refresh_token_expires_at

      t.boolean :revoked, default: false, null: false

      t.timestamps
    end
  end
end
