class AddEmailSignatureIdToUserConfigurations < ActiveRecord::Migration
  def change
    add_column :user_configurations, :email_signature_id, :integer
  end
end
