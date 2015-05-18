# == Schema Information
#
# Table name: gmail_accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  google_id              :text
#  email                  :text
#  verified_email         :boolean
#  sync_started_time      :datetime
#  last_history_id_synced :text
#  created_at             :datetime
#  updated_at             :datetime
#  sync_delayed_job_id    :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gmail_account do
    after(:create) do |gmail_account|
      if gmail_account.google_o_auth2_token.nil?
        gmail_account.google_o_auth2_token = FactoryGirl.create(:google_o_auth2_token, :google_api => gmail_account)
      end
    end

    user

    sequence(:google_id) { |n| "#{n}" }
    sequence(:email) { |n| "email#{n}@gmail.com" }
    verified_email true

    last_history_id_synced nil
  end
end
