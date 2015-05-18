# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sync_failed_email do
    association :email_account, :factory => :gmail_account
    
    sequence(:email_uid) { |n| "#{n}" }
    result nil
    exception nil
  end
end
