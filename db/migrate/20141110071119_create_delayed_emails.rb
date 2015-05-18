class CreateDelayedEmails < ActiveRecord::Migration
  def change
    create_table :delayed_emails do |t|
      t.belongs_to :email_account, polymorphic: true
      t.integer :delayed_job_id
      
      t.text :uid

      t.text :tos, :ccs, :bccs
      t.text :subject
      t.text :html_part, :text_part
      t.text :email_in_reply_to_uid

      t.boolean :tracking_enabled

      t.boolean :bounce_back, :default => false
      t.datetime :bounce_back_time
      t.text :bounce_back_type
      
      t.timestamps
    end

    add_index :delayed_emails, :uid, :unique => true
    add_index :delayed_emails, :delayed_job_id
  end
end
