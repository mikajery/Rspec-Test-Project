require 'rails_helper'

describe 'api/v1/apps/index', :type => :view do
  it 'returns the apps' do
    apps = assign(:apps, FactoryGirl.create_list(:app, SpecMisc::MEDIUM_LIST_SIZE))
    render
    apps_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid name description callback_url)
    apps.zip(apps_rendered).each do |app, app_rendered|
      spec_validate_attributes(expected_attributes, app, app_rendered)
    end
  end
end
