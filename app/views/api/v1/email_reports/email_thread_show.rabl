collection @email_threads

attributes :uid

node :email_subject do |u|
  u.latest_email.subject
end

node :emails_count do |u|
  u.emails_count
end
