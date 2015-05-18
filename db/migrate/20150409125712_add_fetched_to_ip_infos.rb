class AddFetchedToIpInfos < ActiveRecord::Migration
  def change
    add_column :ip_infos, :fetched, :boolean, default: false

    # To remove the uniqueness constraint on the db index
    remove_index :ip_infos, column: :ip, unique: true
    add_index :ip_infos, :ip
  end
end
