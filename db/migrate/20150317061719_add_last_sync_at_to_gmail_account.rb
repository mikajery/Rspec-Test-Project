class AddLastSyncAtToGmailAccount < ActiveRecord::Migration
  def change
    add_column :gmail_accounts, :last_sync_at, :datetime
  end
end
