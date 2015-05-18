class AddAutoFileFolderToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :auto_file_folder_name, :string
  end
end
