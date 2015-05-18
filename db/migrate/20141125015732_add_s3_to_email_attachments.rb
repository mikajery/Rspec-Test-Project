class AddS3ToEmailAttachments < ActiveRecord::Migration
  def change
    add_column :email_attachments, :uid, :text

    add_column :email_attachments, :mime_type, :text
    add_column :email_attachments, :content_disposition, :text
    add_column :email_attachments, :sha256_hex_digest, :text

    add_column :email_attachments, :gmail_attachment_id, :text
    add_column :email_attachments, :s3_key, :text, :unique => true

    add_index :email_attachments, :uid, :unique => true
  end
end
