require 'rails_helper'

describe 'api/v1/email_tracker_views/index', :type => :view do
  it 'returns the email_tracker_views' do
    email_tracker_views = assign(:email_tracker_views, FactoryGirl.create_list(:email_tracker_view, SpecMisc::MEDIUM_LIST_SIZE))
    render
    email_tracker_views_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid ip_address user_agent created_at)
    expected_attributes_to_skip = %w(created_at)

    email_tracker_views.zip(email_tracker_views_rendered).each do |email_tracker_view, email_tracker_view_rendered|
      spec_validate_attributes(expected_attributes, email_tracker_view, email_tracker_view_rendered, expected_attributes_to_skip)
    end
  end
end
