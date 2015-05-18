# == Schema Information
#
# Table name: email_trackers
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  email_uids         :text
#  email_subject      :text
#  email_date         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_tracker do
  	before(:create) do |email_tracker|
      if email_tracker.email_account.nil?
        email_tracker.email_account = FactoryGirl.create(:gmail_account)
      end
    end

  	email_subject FFaker::Lorem.sentence
  	email_date Time.now
  end
end
