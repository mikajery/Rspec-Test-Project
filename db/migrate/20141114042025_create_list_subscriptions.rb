class CreateListSubscriptions < ActiveRecord::Migration
  def change
    create_table :list_subscriptions do |t|
      t.belongs_to :email_account, polymorphic: true
      
      t.text :uid
      
      t.text :list_name
      t.text :list_id
      
      t.text :list_subscribe
      t.text :list_subscribe_mailto
      t.text :list_subscribe_email
      t.text :list_subscribe_link
      
      t.text :list_unsubscribe
      t.text :list_unsubscribe_mailto
      t.text :list_unsubscribe_email
      t.text :list_unsubscribe_link
      
      t.text :list_domain
      
      t.datetime :most_recent_email_date

      t.integer :unsubscribe_delayed_job_id
      t.boolean :unsubscribed, :default => false
      
      t.timestamps
    end

    add_index :list_subscriptions, :uid, :unique => true

    add_index :list_subscriptions, [:email_account_id, :list_id, :list_domain],
              :unique => true, :name => 'index_list_subscriptions_on_ea_id_and_list_id_list_domain'
    
    add_index :list_subscriptions, [:email_account_id, :list_unsubscribe],
              :unique => true, :name => 'index_list_subscriptions_on_ea_id_and_list_unsubscribe'

    add_index :list_subscriptions, [:email_account_id, :list_unsubscribe_mailto],
              :unique => true, :name => 'index_list_subscriptions_on_ea_id_and_list_unsubscribe_mailto'
    
    add_index :list_subscriptions, [:email_account_id, :list_unsubscribe_email],
              :unique => true, :name => 'index_list_subscriptions_on_ea_id_and_list_unsubscribe_email'
    
    add_index :list_subscriptions, [:email_account_id, :list_unsubscribe_link],
              :unique => true, :name => 'index_list_subscriptions_on_ea_id_and_list_unsubscribe_link'
  end
end
