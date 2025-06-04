class CreateSecurialRoleAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :securial_role_assignments, id: :string do |t|
      t.references :user, null: false, type: :string, foreign_key: { to_table: :securial_users }
      t.references :role, null: false, type: :string, foreign_key: { to_table: :securial_roles }

      t.timestamps
    end
  end
end
