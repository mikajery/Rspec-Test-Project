require 'rails_helper'

describe 'api/v1/installed_apps/index', :type => :view do
  it 'returns the installed_apps' do
    installed_apps = assign(:installed_apps, FactoryGirl.create_list(:installed_app, SpecMisc::MEDIUM_LIST_SIZE))
    render
    installed_apps_rendered = JSON.parse(rendered)

    expected_attributes = %w(app installed_app_subclass_type permissions_email_headers permissions_email_content)
    expected_attributes_to_skip = %w(app)

    installed_apps.zip(installed_apps_rendered).each do |installed_app, installed_app_rendered|
      spec_validate_attributes(expected_attributes, installed_app, installed_app_rendered, expected_attributes_to_skip)
    end
  end
end
