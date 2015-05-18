# == Schema Information
#
# Table name: email_references
#
#  id                    :integer          not null, primary key
#  email_id              :integer
#  references_message_id :text
#  position              :integer
#  created_at            :datetime
#  updated_at            :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_reference do
    email

    sequence(:references_message_id) { |n| "foo#{n}@bar.com" } 
    sequence(:position) { |n| n }
  end
end
