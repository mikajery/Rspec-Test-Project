class AddIndicesForDbPerformance < ActiveRecord::Migration
  def change
    add_index :apps, :user_id
    add_index :delayed_emails, [:email_account_id, :email_account_type]
    add_index :email_attachment_uploads, :email_id
    add_index :email_attachment_uploads, :user_id
    add_index :email_attachments, :email_id
    add_index :email_rules, :user_id
    add_index :email_trackers, [:email_account_id, :email_account_type]
    add_index :emails, :ip_info_id
    add_index :emails, [:auto_filed_folder_id, :auto_filed_folder_type]
    add_index :emails, :list_subscription_id
    add_index :genie_rules, :user_id
    add_index :installed_apps, [:installed_app_subclass_id, :installed_app_subclass_type], :name => :installed_apps_index
    add_index :list_subscriptions, [:email_account_id, :email_account_type], :name => :email_account_index
    add_index :user_configurations, :skin_id
    add_index :user_configurations, :email_signature_id
  end
end