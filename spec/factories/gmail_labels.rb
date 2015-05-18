# == Schema Information
#
# Table name: gmail_labels
#
#  id                      :integer          not null, primary key
#  gmail_account_id        :integer
#  label_id                :text
#  name                    :text
#  message_list_visibility :text
#  label_list_visibility   :text
#  label_type              :text
#  created_at              :datetime
#  updated_at              :datetime
#  num_threads             :integer          default(0)
#  num_unread_threads      :integer          default(0)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gmail_label do
    gmail_account

    sequence(:label_id) { |n| "Label ID #{n}" }
    sequence(:name) { |n| "Label Name #{n}" }
    message_list_visibility true
    label_list_visibility true
    label_type 'user'
  end

  factory :gmail_label_inbox, :parent => :gmail_label do
    label_id 'INBOX'
    name 'INBOX'
    label_type 'system'
  end

  factory :gmail_label_sent, :parent => :gmail_label do
    label_id 'SENT'
    name 'SENT'
    label_type 'system'
  end

  factory :gmail_label_drafts, :parent => :gmail_label do
    label_id 'DRAFT'
    name 'DRAFT'
    label_type 'system'
  end

  factory :gmail_label_trash, :parent => :gmail_label do
    label_id 'TRASH'
    name 'TRASH'
    label_type 'system'
  end

  factory :gmail_label_spam, :parent => :gmail_label do
    label_id 'SPAM'
    name 'SPAM'
    label_type 'system'
  end

  factory :gmail_label_starred, :parent => :gmail_label do
    label_id 'STARRED'
    name 'STARRED'
    label_type 'system'
  end
end
