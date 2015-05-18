# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  admin                :boolean          default(FALSE)
#  email                :text
#  password_digest      :text
#  login_attempt_count  :integer          default(0)
#  has_genie_report_ran :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  profile_picture      :string(255)
#  name                 :string(255)
#  given_name           :string(255)
#  family_name          :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@bar.com" }
    password 'Foobar!1'
    password_confirmation 'Foobar!1'

    factory :user_with_email_rules do

      ignore do
        email_rules_count 2
      end

      after(:create) do |user, evaluator|
        create_list(:email_rule, evaluator.email_rules_count, user: user)
      end
    end

    factory :user_with_gmail_accounts do

      ignore do
        gmail_accounts_count 2
      end

      after(:create) do |user, evaluator|
        create_list(:gmail_account, evaluator.gmail_accounts_count, user: user)
      end
    end
  end

  factory :locked_user, :parent => :user do
    login_attempt_count $config.max_login_attempts
  end
end
