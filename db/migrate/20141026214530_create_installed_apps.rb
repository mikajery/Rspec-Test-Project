class CreateInstalledApps < ActiveRecord::Migration
  def change
    create_table :installed_apps do |t|
      t.belongs_to :installed_app_subclass, polymorphic: true
      
      t.belongs_to :user
      t.belongs_to :app

      t.boolean :permissions_email_headers, :default => false
      t.boolean :permissions_email_content, :default => false

      t.timestamps
    end

    add_index :installed_apps, [:user_id, :app_id], :unique => true
  end
end
