class AddQueuedAutoFileToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :queued_auto_file, :boolean, :default => false
  end
end
