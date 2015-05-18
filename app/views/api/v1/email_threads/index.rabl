collection @email_threads

attributes :uid

node :emails do |u|
  [partial("api/v1/emails/show", object: u.latest_email)]
end

# for backward-compatibility: existing records don't have cached count
node :emails_count do |u|
  u.emails_count
end
