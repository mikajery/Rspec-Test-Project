# == Schema Information
#
# Table name: email_rules
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  uid                     :text
#  from_address            :text
#  to_address              :text
#  subject                 :text
#  list_id                 :text
#  destination_folder_name :text
#  created_at              :datetime
#  updated_at              :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_rule do
    user

    sequence(:uid) { |n| n.to_s }
    sequence(:list_id) { |n| "sales_#{n}.turinginc.com" }
    sequence(:destination_folder_name) { |n| "sales_#{n}" }
  end
end
