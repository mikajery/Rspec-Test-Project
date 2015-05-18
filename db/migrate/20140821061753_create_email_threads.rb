class CreateEmailThreads < ActiveRecord::Migration
  def change
    create_table :email_threads do |t|
      t.belongs_to :email_account, polymorphic: true
      t.text :uid

      t.timestamps
    end

    add_index :email_threads, [:email_account_id, :email_account_type, :uid],
              :unique => true, :name => 'index_email_threads_on_email_account_and_uid'
    add_index :email_threads, [:email_account_id, :email_account_type]
    add_index :email_threads, :uid, :unique => true
  end
end
