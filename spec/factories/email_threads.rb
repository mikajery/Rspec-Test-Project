# == Schema Information
#
# Table name: email_threads
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  created_at         :datetime
#  updated_at         :datetime
#  emails_count       :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_thread do
    association :email_account, :factory => :gmail_account
    sequence(:uid) { |n| "#{n}" }
  end
end
