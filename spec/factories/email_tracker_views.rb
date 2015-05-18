# == Schema Information
#
# Table name: email_tracker_views
#
#  id                         :integer          not null, primary key
#  email_tracker_recipient_id :integer
#  uid                        :text
#  ip_address                 :text
#  user_agent                 :text
#  created_at                 :datetime
#  updated_at                 :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_tracker_view do
  	before(:create) do |email_tracker_view|
      if email_tracker_view.email_tracker_recipient.nil?
        email_tracker_view.email_tracker_recipient = FactoryGirl.create(:email_tracker_recipient)
      end
    end
    ip_address FFaker::Internet.ip_v4_address
  end
end
