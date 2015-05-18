object @user

attributes :email, :has_genie_report_ran, :profile_picture, :name, :given_name, :family_name

node(:num_emails) do |user|
  user.emails.count
end