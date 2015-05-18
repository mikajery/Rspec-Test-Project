# == Schema Information
#
# Table name: email_attachment_uploads
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  email_id    :integer
#  uid         :text
#  s3_key      :text
#  s3_key_full :text
#  filename    :text
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_attachment_upload do
  	user
  end
end
