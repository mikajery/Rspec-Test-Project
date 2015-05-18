class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.boolean :admin, :default => false
      
      t.text :email
      t.text :password_digest

      t.integer :login_attempt_count, :default => 0
      
      t.boolean :has_genie_report_ran, :default => false

      t.timestamps
    end

    add_index :users, :email, :unique => true
  end
end
