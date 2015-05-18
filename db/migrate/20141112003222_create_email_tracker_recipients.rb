class CreateEmailTrackerRecipients < ActiveRecord::Migration
  def change
    create_table :email_tracker_recipients do |t|
      t.belongs_to :email_tracker
      t.belongs_to :email
      
      t.text :uid
      t.text :email_address
      
      t.timestamps
    end

    add_index :email_tracker_recipients, :email_tracker_id
    add_index :email_tracker_recipients, :email_id
    add_index :email_tracker_recipients, :uid, :unique => true
  end
end
