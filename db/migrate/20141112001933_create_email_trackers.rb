class CreateEmailTrackers < ActiveRecord::Migration
  def change
    create_table :email_trackers do |t|
      t.belongs_to :email_account, polymorphic: true
      
      t.text :uid
      
      t.text :email_uids
      t.text :email_subject
      t.datetime :email_date

      t.timestamps
    end

    add_index :email_trackers, :email_account_id
    add_index :email_trackers, :uid, :unique => true
  end
end
