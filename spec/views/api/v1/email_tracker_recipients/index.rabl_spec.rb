require 'rails_helper'

describe 'api/v1/email_tracker_recipients/index', :type => :view do
  it 'returns the email_tracker_recipients' do
    email_tracker_recipients = assign(:email_tracker_recipients, FactoryGirl.create_list(:email_tracker_recipient, SpecMisc::MEDIUM_LIST_SIZE))
    render
    email_tracker_recipients_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid email_tracker_views email_address)

    email_tracker_recipients.zip(email_tracker_recipients_rendered).each do |email_tracker_recipient, email_tracker_recipient_rendered|
      spec_validate_attributes(expected_attributes, email_tracker_recipient, email_tracker_recipient_rendered)
    end
  end
end
