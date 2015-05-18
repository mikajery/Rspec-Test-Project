# == Schema Information
#
# Table name: email_tracker_recipients
#
#  id               :integer          not null, primary key
#  email_tracker_id :integer
#  email_id         :integer
#  uid              :text
#  email_address    :text
#  created_at       :datetime
#  updated_at       :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_tracker_recipient do
  	before(:create) do |email_tracker_recipient|
      if email_tracker_recipient.email_tracker.nil?
        email_tracker_recipient.email_tracker = FactoryGirl.create(:email_tracker)
      end
    end
  	email_address FFaker::Address.city
  end
end
