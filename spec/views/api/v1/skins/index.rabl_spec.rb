require 'rails_helper'

describe 'api/v1/skins/index', :type => :view do
  it 'returns the skins' do
    skins = assign(:skins, FactoryGirl.create_list(:skin, SpecMisc::MEDIUM_LIST_SIZE))
    render
    skins_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid name)

    skins.zip(skins_rendered).each do |skin, skin_rendered|
      spec_validate_attributes(expected_attributes, skin, skin_rendered)
    end
  end
end
