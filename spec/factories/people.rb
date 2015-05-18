# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  email_address      :text
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    association :email_account, :factory => :gmail_account
    
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email_address) { |n| "foo#{n}@bar.com" }
  end
end
