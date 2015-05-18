# == Schema Information
#
# Table name: installed_apps
#
#  id                          :integer          not null, primary key
#  installed_app_subclass_id   :integer
#  installed_app_subclass_type :string(255)
#  user_id                     :integer
#  app_id                      :integer
#  permissions_email_headers   :boolean          default(FALSE)
#  permissions_email_content   :boolean          default(FALSE)
#  created_at                  :datetime
#  updated_at                  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :installed_app do
  	association :app, :factory => :app
  	association :user, :factory => :user
  end
end
