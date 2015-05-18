object @delayed_email

attributes :uid, :tos, :ccs, :bccs, :subject, :html_part, :text_part, :email_in_reply_to_uid, :tracking_enabled, :bounce_back, :bounce_back_time, :bounce_back_type, :attachment_s3_keys

node(:send_at) do |delayed_email|
  delayed_email.send_at()
end