# == Schema Information
#
# Table name: emails
#
#  id                                :integer          not null, primary key
#  email_account_id                  :integer
#  email_account_type                :string(255)
#  email_thread_id                   :integer
#  ip_info_id                        :integer
#  auto_filed                        :boolean          default(FALSE)
#  auto_filed_reported               :boolean          default(FALSE)
#  auto_filed_folder_id              :integer
#  auto_filed_folder_type            :string(255)
#  uid                               :text
#  draft_id                          :text
#  message_id                        :text
#  list_name                         :text
#  list_id                           :text
#  seen                              :boolean          default(FALSE)
#  snippet                           :text
#  date                              :datetime
#  from_name                         :text
#  from_address                      :text
#  sender_name                       :text
#  sender_address                    :text
#  reply_to_name                     :text
#  reply_to_address                  :text
#  tos                               :text
#  ccs                               :text
#  bccs                              :text
#  subject                           :text
#  html_part                         :text
#  text_part                         :text
#  body_text                         :text
#  has_calendar_attachment           :boolean          default(FALSE)
#  list_subscription_id              :integer
#  bounce_back                       :boolean          default(FALSE)
#  bounce_back_time                  :datetime
#  bounce_back_type                  :text
#  bounce_back_job_id                :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  auto_file_folder_name             :string(255)
#  queued_auto_file                  :boolean          default(FALSE)
#  upload_attachments_delayed_job_id :integer
#  attachments_uploaded              :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    before(:create) do |email|
      if email.email_account.nil?
        email.email_account = email.email_thread ? email.email_thread.email_account : FactoryGirl.create(:gmail_account)
      end
      
      email.email_thread = FactoryGirl.create(:email_thread, :email_account => email.email_account) if email.email_thread.nil?
    end

    auto_filed false
    auto_filed_reported false
    auto_filed_folder nil
    auto_file_folder_name ""

    sequence(:uid) { |n| "#{n}" }
    sequence(:message_id) { |n| "foo#{n}@bar.com" }
    list_id 'test_list'

    seen false
    sequence(:snippet) { |n| "test email #{n} snippet" }

    date { DateTime.now.rfc2822 }

    email_attachments []
    email_attachment_uploads []

    from_name 'From Name'
    from_address 'from@address.com'

    sender_name 'Sender Name'
    sender_address 'sender@address.com'

    reply_to_name 'Reply To Name'
    reply_to_address 'reply_to@address.com'
    
    sequence(:subject) { |n| "Test Subject #{n}" }
    
    html_part '<html>Test email text</html>'
    text_part 'Test email text'
    body_text nil

    has_calendar_attachment false

    factory :email_with_email_recipients do

      ignore do
        email_recipients_count 3
      end

      after(:create) do |email, evaluator|
        create_list(:email_recipient, evaluator.email_recipients_count, email: email)
      end
    end
  end

  factory :seen_email, :parent => :email do
    seen true
  end
end
