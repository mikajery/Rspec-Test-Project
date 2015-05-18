class AddSortIndexToEmailFolderMappings < ActiveRecord::Migration
  def change
    add_index :email_folder_mappings, [:email_folder_id, :email_folder_type,
                                       :folder_email_thread_date, :email_thread_id, :email_id],
              :name => 'index_email_folder_mappings_sort'
  end
end

