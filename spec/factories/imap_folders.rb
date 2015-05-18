# == Schema Information
#
# Table name: imap_folders
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :imap_folder do
    association :email_account, :factory => :gmail_account

    sequence(:name) { |n| "Folder Name #{n}" }
  end
end
