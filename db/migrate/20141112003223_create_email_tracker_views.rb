class CreateEmailTrackerViews < ActiveRecord::Migration
  def change
    create_table :email_tracker_views do |t|
      t.belongs_to :email_tracker_recipient

      t.text :uid
      
      t.text :ip_address
      t.text :user_agent
      
      t.timestamps
    end

    add_index :email_tracker_views, :email_tracker_recipient_id
    add_index :email_tracker_views, :uid, :unique => true
  end
end
