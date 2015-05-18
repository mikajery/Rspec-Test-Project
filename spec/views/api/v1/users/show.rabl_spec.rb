require 'rails_helper'

describe 'api/v1/users/show', :type => :view do
  it 'should render the user' do
    user = assign(:user, FactoryGirl.create(:user))
    render
    user_rendered = JSON.parse(rendered)

    expected_attributes = %w(email family_name given_name has_genie_report_ran name num_emails profile_picture)
    expected_attributes_to_skip = %w(num_emails)
    
    spec_validate_attributes(expected_attributes, user, user_rendered, expected_attributes_to_skip)
    expect(user_rendered["num_emails"]).to eq(user.emails.count)
  end
end
