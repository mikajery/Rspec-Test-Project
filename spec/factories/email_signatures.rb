# == Schema Information
#
# Table name: email_signatures
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uid        :text
#  name       :text
#  text       :text
#  html       :text
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_signature do
    sequence(:name) { |n| "Name #{n}" }
  end
end
