class AddInboxTabsEnabledToUserConfigurations < ActiveRecord::Migration
  def change
    add_column :user_configurations, :inbox_tabs_enabled, :boolean
  end
end
