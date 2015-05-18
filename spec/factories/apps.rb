# == Schema Information
#
# Table name: apps
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  name         :text
#  description  :text
#  app_type     :text
#  callback_url :text
#  created_at   :datetime
#  updated_at   :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

require 'ffaker'

FactoryGirl.define do
  factory :app do
  	association :user, :factory => :user
  	
    sequence(:uid) { |n| n.to_s }
    sequence(:name) { |n| "Name #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    sequence(:callback_url) { |n| "Url #{n}" }
  	app_type :panel
  end
end
