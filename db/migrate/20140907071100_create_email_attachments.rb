class CreateEmailAttachments < ActiveRecord::Migration
  def change
    create_table :email_attachments do |t|
      t.belongs_to :email
      
      t.text :filename
      t.text :content_type
      t.integer :file_size
      
      t.timestamps
    end
  end
end
