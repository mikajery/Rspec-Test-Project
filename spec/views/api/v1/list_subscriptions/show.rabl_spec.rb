require 'rails_helper'

describe 'api/v1/list_subscriptions/show', :type => :view do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }

  it 'should render a list_subscription' do
    list_subscription = FactoryGirl.build(:list_subscription)
    list_subscription.email_account = gmail_account
    list_subscription.unsubscribed = false
    list_subscription.unsubscribe_delayed_job_id = nil
    list_subscription.save!
    list_subscription = assign(:list_subscription, list_subscription)

    render

    list_subscription_rendered = JSON.parse(rendered)

    expected_attributes = %w(list_name
                             list_id
                             list_domain
                             unsubscribed)

    spec_validate_attributes(expected_attributes, list_subscription, list_subscription_rendered)
  end
end
