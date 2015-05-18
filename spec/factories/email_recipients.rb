# == Schema Information
#
# Table name: email_recipients
#
#  id             :integer          not null, primary key
#  email_id       :integer
#  person_id      :integer
#  recipient_type :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_recipient do
    email
    person

    recipient_type EmailRecipient.recipient_types[:to]
  end
end
