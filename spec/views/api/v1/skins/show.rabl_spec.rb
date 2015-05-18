require 'rails_helper'

describe 'api/v1/skins/show', :type => :view do
  it 'should render a skin' do
    skin = assign(:skin, FactoryGirl.create(:skin))

    render

    skin_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             name)

    spec_validate_attributes(expected_attributes, skin, skin_rendered)
  end
end
