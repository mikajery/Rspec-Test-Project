# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mime_type_mapping do
    mime_type "MyString"
    usable_category_cd 1
  end
end
