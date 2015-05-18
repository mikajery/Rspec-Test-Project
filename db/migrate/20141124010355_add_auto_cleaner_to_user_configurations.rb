class AddAutoCleanerToUserConfigurations < ActiveRecord::Migration
  def change
    add_column :user_configurations, :auto_cleaner_enabled, :boolean, :default => false
  end
end
