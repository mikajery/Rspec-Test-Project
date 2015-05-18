class AddCountsToGmailLabels < ActiveRecord::Migration
  def change
    add_column :gmail_labels, :num_threads, :integer, :default => 0
    add_column :gmail_labels, :num_unread_threads, :integer, :default => 0
  end
end
