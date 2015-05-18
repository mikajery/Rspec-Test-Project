class CreateEmailAttachmentUploads < ActiveRecord::Migration
  def change
    create_table :email_attachment_uploads do |t|
      t.belongs_to :user
      t.belongs_to :email
      
      t.text :uid
      
      t.text :s3_key
      t.text :s3_key_full
      
      t.text :filename

      t.timestamps
    end
    
    add_index :email_attachment_uploads, :uid, :unique => true
    add_index :email_attachment_uploads, :s3_key, :unique => true
    add_index :email_attachment_uploads, :s3_key_full, :unique => true
  end
end
