# == Schema Information
#
# Table name: user_auth_keys
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  encrypted_auth_key :text
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_auth_key do
    user

    sequence(:encrypted_auth_key) { |n| "encrypted_auth_key #{n}" }
  end
end
