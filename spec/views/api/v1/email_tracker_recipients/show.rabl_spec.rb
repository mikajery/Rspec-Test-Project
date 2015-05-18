require 'rails_helper'

describe 'api/v1/email_tracker_recipients/show', :type => :view do
  it 'should render a email_tracker_recipient' do
    email_tracker_recipient = assign(:email_tracker_recipient, FactoryGirl.create(:email_tracker_recipient))

    render

    email_tracker_recipient_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             email_tracker_views
                             email_address)

    spec_validate_attributes(expected_attributes, email_tracker_recipient, email_tracker_recipient_rendered)
  end
end
