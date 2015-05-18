class CreateIndicesToOptimizeQueries < ActiveRecord::Migration
  def change
    add_index :emails, :updated_at, name: "updated_at_index_on_emails", :order => {:updated_at => "desc"}
    add_index :emails, :auto_file_folder_name
  end
end