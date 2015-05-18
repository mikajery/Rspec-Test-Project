require 'rails_helper'

describe 'api/v1/apps/show', :type => :view do
  it 'should render a app' do
    app = assign(:app, FactoryGirl.create(:app))

    render

    app_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             name
                             description
                             callback_url)

    spec_validate_attributes(expected_attributes, app, app_rendered)
  end
end
