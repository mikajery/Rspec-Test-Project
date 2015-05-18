class CreateSyncFailedEmails < ActiveRecord::Migration
  def change
    create_table :sync_failed_emails do |t|
      t.belongs_to :email_account, polymorphic: true
      
      t.text :email_uid
      t.text :result
      t.text :exception

      t.timestamps
    end

    add_index :sync_failed_emails, [:email_account_id, :email_account_type, :email_uid],
              :unique => true, :name => 'index_sync_failed_emails_on_email_account_and_email_uid'
  end
end
