object @email_thread

attributes :uid

child(@email_thread.emails.includes([:email_attachments, :email_attachment_uploads, :gmail_labels]).page(params[:page]).per(25) => :emails) do |email|
  extends('api/v1/emails/show')
end

attributes :emails_count do |email_thread|
  email_thread.emails_count
end