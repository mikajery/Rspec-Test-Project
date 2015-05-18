object @email_tracker_recipient

attributes :uid, :email_address

child(:email_tracker_views) do |email_tracker_view|
  extends('api/v1/email_tracker_views/show')
end
