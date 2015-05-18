require 'rails_helper'

describe 'api/v1/email_trackers/index', :type => :view do
  it 'returns the email_trackers' do
    email_trackers = assign(:email_trackers, FactoryGirl.create_list(:email_tracker, SpecMisc::MEDIUM_LIST_SIZE))
    render
    email_trackers_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid email_tracker_recipients email_subject email_date)
    expected_attributes_to_skip = %w(email_date)
    email_trackers.zip(email_trackers_rendered).each do |email_tracker, email_tracker_rendered|
      spec_validate_attributes(expected_attributes, email_tracker, email_tracker_rendered, expected_attributes_to_skip)
    end
  end
end
