class CreateEmailRecipients < ActiveRecord::Migration
  def change
    create_table :email_recipients do |t|
      t.belongs_to :email
      t.belongs_to :person
      
      t.integer :recipient_type

      t.timestamps
    end

    add_index :email_recipients, [:email_id, :person_id, :recipient_type],
              :unique => true, :name => 'index_email_recipients_on_email_and_person_and_recipient_type'
    add_index :email_recipients, :email_id
  end
end
