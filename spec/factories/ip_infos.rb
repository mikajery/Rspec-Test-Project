# == Schema Information
#
# Table name: ip_infos
#
#  id           :integer          not null, primary key
#  ip           :inet
#  country_code :text
#  country_name :text
#  region_code  :text
#  region_name  :text
#  city         :text
#  zipcode      :text
#  latitude     :text
#  longitude    :text
#  metro_code   :text
#  area_code    :text
#  created_at   :datetime
#  updated_at   :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ip_info do
    sequence(:ip) { |n| "76.21.112.#{n}" }
    country_code 'US'
    country_name 'United States'
    region_code 'CA'
    region_name 'California'
    city 'Menlo Park'
    zipcode '94025'
    latitude '37.4498'
    longitude '-122.2004'
    metro_code '807'
    area_code '650'
  end
end
