class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.belongs_to :email_account, polymorphic: true
      t.text :name
      t.text :email_address
      
      t.timestamps
    end

    add_index :people, [:email_account_id, :email_account_type, :email_address],
              :unique => true, :name => 'index_people_on_email_account_and_email_address'
  end
end
