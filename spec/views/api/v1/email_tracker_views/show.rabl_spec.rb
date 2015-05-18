require 'rails_helper'

describe 'api/v1/email_tracker_views/show', :type => :view do
  it 'should render a email_tracker_view' do
    email_tracker_view = assign(:email_tracker_view, FactoryGirl.create(:email_tracker_view))

    render

    email_tracker_view_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             ip_address
                             user_agent
                             created_at)
    expected_attributes_to_skip = %w(created_at)
    spec_validate_attributes(expected_attributes, email_tracker_view, email_tracker_view_rendered, expected_attributes_to_skip)
  end
end
