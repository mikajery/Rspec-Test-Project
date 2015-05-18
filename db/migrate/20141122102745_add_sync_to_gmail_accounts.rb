class AddSyncToGmailAccounts < ActiveRecord::Migration
  def change
    add_column :gmail_accounts, :sync_delayed_job_id, :integer
  end
end
