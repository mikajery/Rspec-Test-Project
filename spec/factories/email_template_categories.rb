# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_template_category do
    sequence(:name) { |n| "Name #{n}" }
    email_templates_count 0
  end
end
