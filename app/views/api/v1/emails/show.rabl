object @email

attributes :auto_filed
attributes :uid, :draft_id, :message_id, :list_id
attributes :seen, :snippet, :date

attributes :from_name, :from_address
attributes :sender_name, :sender_address
attributes :reply_to_name, :reply_to_address

attributes :tos, :ccs, :bccs
attributes :subject
attributes :html_part, :text_part, :body_text

attributes :auto_file_folder_name

node(:email_attachments) do |email|
  partial('api/v1/email_attachments/index', object: email.email_attachments)
end

node(:email_attachment_uploads) do |email|
  partial('api/v1/email_attachment_uploads/index', object: email.email_attachment_uploads)
end

#child(:gmail_labels, :if => lambda { |email| email.email_account_type == "GmailAccount" }) do |gmail_label|
#  extends('api/v1/gmail_labels/show', :locals => {:no_counts => true})
#end

# faster version with less info
node(:folder_ids, :if => lambda { |email| email.email_account_type == "GmailAccount" }) do |email|
  email.gmail_labels.map {|gmail_label| gmail_label.label_id}
end

#child(:imap_folders, :if => lambda { |email| email.email_account_type == "ImapFolder" }) do |imap_folder|
#  extends('api/v1/imap_folders/show', :locals => {:no_counts => true})
#end

# faster version with less info
node(:folder_ids, :if => lambda { |email| email.email_account_type == "ImapFolder" }) do |email|
  email.imap_folders.map {|imap_folder| imap_folder.label_id}
end