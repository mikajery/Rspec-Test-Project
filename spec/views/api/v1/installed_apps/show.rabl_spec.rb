require 'rails_helper'

describe 'api/v1/installed_apps/show', :type => :view do
  it 'should render a installed_app' do
    installed_app = assign(:installed_app, FactoryGirl.create(:installed_app))

    render

    installed_app_rendered = JSON.parse(rendered)

    expected_attributes = %w(app
                             installed_app_subclass_type
                             permissions_email_headers
                             permissions_email_content)
    expected_attributes_to_skip = %w(app)

    spec_validate_attributes(expected_attributes, installed_app, installed_app_rendered, expected_attributes_to_skip)
  end
end
