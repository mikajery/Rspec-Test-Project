# == Schema Information
#
# Table name: list_subscriptions
#
#  id                         :integer          not null, primary key
#  email_account_id           :integer
#  email_account_type         :string(255)
#  uid                        :text
#  list_name                  :text
#  list_id                    :text
#  list_subscribe             :text
#  list_subscribe_mailto      :text
#  list_subscribe_email       :text
#  list_subscribe_link        :text
#  list_unsubscribe           :text
#  list_unsubscribe_mailto    :text
#  list_unsubscribe_email     :text
#  list_unsubscribe_link      :text
#  list_domain                :text
#  most_recent_email_date     :datetime
#  unsubscribe_delayed_job_id :integer
#  unsubscribed               :boolean          default(FALSE)
#  created_at                 :datetime
#  updated_at                 :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list_subscription do
    list_unsubscribe FFaker::Lorem.sentence
    sequence(:list_id) { |n| "List ID #{n}" }
    sequence(:list_name) { |n| "List Name #{n}" }
    sequence(:list_domain) { |n| "List Domain #{n}" }

    before(:create) do |list_subscription|
      if list_subscription.email_account.nil?
        list_subscription.email_account = FactoryGirl.create(:gmail_account)
      end
    end
  end
end
