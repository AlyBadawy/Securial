class CreateSecurialRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :securial_roles, id: :string do |t|
      t.string :role_name
      t.boolean :hide_from_profile, default: false, null: false

      t.timestamps
    end
  end
end
