class AddEmailListViewRowHeightToUserConfigurations < ActiveRecord::Migration
  def change
    add_column :user_configurations, :email_list_view_row_height, :integer
  end
end
