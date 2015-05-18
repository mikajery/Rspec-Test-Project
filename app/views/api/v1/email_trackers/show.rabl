object @email_tracker

attributes :uid, :email_subject, :email_date

child(:email_tracker_recipients) do |email_tracker_recipient|
  extends('api/v1/email_tracker_recipients/show')
end
