class CreateUserConfigurations < ActiveRecord::Migration
  def change
    create_table :user_configurations do |t|
      t.belongs_to :user

      t.boolean :demo_mode_enabled, :default => true
      t.boolean :keyboard_shortcuts_enabled, :default => true
      t.boolean :genie_enabled, :default => true
      t.text :split_pane_mode, :default => 'horizontal'
      t.boolean :developer_enabled, :default => false
      t.belongs_to :skin

      t.timestamps
    end

    add_index :user_configurations, :user_id, :unique => true
  end
end
