# == Schema Information
#
# Table name: email_templates
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uid        :text
#  name       :text
#  text       :text
#  html       :text
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_template do
    sequence(:name) { |n| "Name #{n}" }
    html { FFaker::Lorem.paragraph }
  end
end
