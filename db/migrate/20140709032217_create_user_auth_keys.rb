class CreateUserAuthKeys < ActiveRecord::Migration
  def change
    create_table :user_auth_keys do |t|
      t.belongs_to :user
      t.text :encrypted_auth_key

      t.timestamps
    end

    add_index :user_auth_keys, :user_id
    add_index :user_auth_keys, :encrypted_auth_key
  end
end
