# == Schema Information
#
# Table name: email_folder_mappings
#
#  id                       :integer          not null, primary key
#  email_id                 :integer
#  email_folder_id          :integer
#  email_folder_type        :string(255)
#  email_thread_id          :integer
#  folder_email_date        :datetime
#  folder_email_draft_id    :text
#  folder_email_thread_date :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_folder_mapping do
    before(:create) do |email_folder_mapping|
      if email_folder_mapping.email_folder.nil?
        email_folder_mapping.email_folder = FactoryGirl.create(:gmail_label, :gmail_account => email_folder_mapping.email.email_account)
      end

      if email_folder_mapping.email_thread.nil?
        email_folder_mapping.email_thread = FactoryGirl.create(:email_thread)
      end
    end

    email
  end
end
