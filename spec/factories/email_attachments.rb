# == Schema Information
#
# Table name: email_attachments
#
#  id                  :integer          not null, primary key
#  email_id            :integer
#  filename            :text
#  content_type        :text
#  file_size           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  uid                 :text
#  mime_type           :text
#  content_disposition :text
#  sha256_hex_digest   :text
#  gmail_attachment_id :text
#  s3_key              :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_attachment do
    email
    sequence(:uid) { |n| n.to_s }
    sequence(:filename) { |n| "file_#{n}.txt" }
    content_type 'image/png'
    file_size 100
  end
end
