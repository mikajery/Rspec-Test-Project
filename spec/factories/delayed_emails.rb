# == Schema Information
#
# Table name: delayed_emails
#
#  id                    :integer          not null, primary key
#  email_account_id      :integer
#  email_account_type    :string(255)
#  delayed_job_id        :integer
#  uid                   :text
#  tos                   :text
#  ccs                   :text
#  bccs                  :text
#  subject               :text
#  html_part             :text
#  text_part             :text
#  email_in_reply_to_uid :text
#  tracking_enabled      :boolean
#  bounce_back           :boolean          default(FALSE)
#  bounce_back_time      :datetime
#  bounce_back_type      :text
#  created_at            :datetime
#  updated_at            :datetime
#  attachment_s3_keys    :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delayed_email do
  end
end
