class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.belongs_to :email_account, polymorphic: true
      t.belongs_to :email_thread
      
      t.belongs_to :ip_info

      t.boolean :auto_filed, :default => false
      t.boolean :auto_filed_reported, :default => false
      t.belongs_to :auto_filed_folder, polymorphic: true

      t.text :uid
      t.text :draft_id
      t.text :message_id
      t.text :list_name
      t.text :list_id

      t.boolean :seen, :default => false
      t.text :snippet

      t.datetime :date

      t.text :from_name, :from_address
      t.text :sender_name, :sender_address
      t.text :reply_to_name, :reply_to_address

      t.text :tos, :ccs, :bccs
      t.text :subject

      t.text :html_part
      t.text :text_part
      t.text :body_text

      t.boolean :has_calendar_attachment, :default => false

      t.belongs_to :list_subscription

      t.boolean :bounce_back, :default => false
      t.datetime :bounce_back_time
      t.text :bounce_back_type
      t.integer :bounce_back_job_id

      t.timestamps
    end

    add_index :emails, [:email_account_id, :email_account_type]
    add_index :emails, [:email_account_id, :email_account_type, :uid], :unique => true
    add_index :emails, [:email_account_id, :email_account_type, :draft_id],
              :unique => true, :name => 'index_emails_on_email_account_and_draft_id'
    
    add_index :emails, :id, :where => 'NOT seen'
    add_index :emails, :uid, :unique => true
    add_index :emails, :message_id
    add_index :emails, :email_thread_id
    
    add_index :emails, :date, :order => {:date => :desc}
    add_index :emails, [:date, :id], :order => {:date => :desc, :id => :desc}
  end
end
