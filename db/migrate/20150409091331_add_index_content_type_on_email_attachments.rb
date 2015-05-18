class AddIndexContentTypeOnEmailAttachments < ActiveRecord::Migration
  def change
    add_index :email_attachments, :content_type
  end
end
