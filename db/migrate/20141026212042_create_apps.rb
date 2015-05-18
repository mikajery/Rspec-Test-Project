class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.belongs_to :user

      t.text :uid
      
      t.text :name
      t.text :description
      t.text :app_type

      t.text :callback_url
      
      t.timestamps
    end

    add_index :apps, :uid, :unique => true
    add_index :apps, :name, :unique => true
  end
end
