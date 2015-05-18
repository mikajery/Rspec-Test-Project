require 'rails_helper'

describe 'api/v1/email_trackers/show', :type => :view do
  it 'should render a email_tracker' do
    email_tracker = assign(:email_tracker, FactoryGirl.create(:email_tracker))

    render

    email_tracker_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             email_tracker_recipients
                             email_subject
                             email_date)

    expected_attributes_to_skip = %w(email_date)
    spec_validate_attributes(expected_attributes, email_tracker, email_tracker_rendered, expected_attributes_to_skip)
  end
end
