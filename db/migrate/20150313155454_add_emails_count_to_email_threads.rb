class AddEmailsCountToEmailThreads < ActiveRecord::Migration
  def change
    add_column :email_threads, :emails_count, :integer
  end
end
