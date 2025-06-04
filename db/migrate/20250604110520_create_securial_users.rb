class CreateSecurialUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :securial_users, id: :string do |t|
      t.string    :email_address, null: false
      t.boolean   :email_verified, null: false, default: false
      t.string    :email_verification_token
      t.datetime  :email_verification_token_created_at
      t.string    :username, null: false
      t.string    :first_name
      t.string    :last_name
      t.string    :phone
      t.string    :bio
      t.string    :password_digest
      t.datetime  :password_changed_at
      t.string    :reset_password_token
      t.datetime  :reset_password_token_created_at
      t.boolean   :locked, null: false, default: false
      t.datetime  :locked_at

      t.timestamps
    end

    add_index :securial_users, :email_address, unique: true
    add_index :securial_users, :username, unique: true
  end
end
