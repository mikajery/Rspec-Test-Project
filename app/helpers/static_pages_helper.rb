module StaticPagesHelper
  def upload_attachment_post
    email_attachment_upload = EmailAttachmentUpload.new
    email_attachment_upload.user = current_user
    email_attachment_upload.save!

    presigned_post = email_attachment_upload.presigned_post()

    {:url => presigned_post.url.to_s, :fields => presigned_post.fields}
  end

  def email_folders
    GmailLabel.where(:gmail_account => current_user.gmail_accounts.first)
  end
end
