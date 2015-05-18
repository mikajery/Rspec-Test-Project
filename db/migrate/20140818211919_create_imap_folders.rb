class CreateImapFolders < ActiveRecord::Migration
  def change
    create_table :imap_folders do |t|
      t.belongs_to :email_account, polymorphic: true

      t.text :name

      t.timestamps
    end

    add_index :imap_folders, [:email_account_id, :email_account_type, :name],
                             :unique => true, :name =>  'index_imap_folders_on_email_account_and_name'
    add_index :imap_folders, [:email_account_id, :email_account_type],
                             :name =>  'index_imap_folders_on_email_account'
  end
end
