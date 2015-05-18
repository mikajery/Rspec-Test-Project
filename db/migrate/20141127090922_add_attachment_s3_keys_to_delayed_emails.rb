class AddAttachmentS3KeysToDelayedEmails < ActiveRecord::Migration
  def change
    add_column :delayed_emails, :attachment_s3_keys, :text
  end
end
