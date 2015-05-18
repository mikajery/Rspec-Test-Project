class AddSyncLockForGmailAccounts < ActiveRecord::Migration
  def change
    add_column :gmail_accounts, :sync_lock, :boolean
  end
end
