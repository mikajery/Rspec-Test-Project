# == Schema Information
#
# Table name: skins
#
#  id         :integer          not null, primary key
#  uid        :text
#  name       :text
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :skin do
    name FFaker::Name.name
  end
end
