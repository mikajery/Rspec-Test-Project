require 'rails_helper'

describe 'api/v1/people/index', :type => :view do
  it 'returns the people' do
    people = assign(:people, FactoryGirl.create_list(:skin, SpecMisc::MEDIUM_LIST_SIZE))
    render
    people_rendered = JSON.parse(rendered)

    expected_attributes = %w(name)

    people.zip(people_rendered).each do |skin, skin_rendered|
      spec_validate_attributes(expected_attributes, skin, skin_rendered)
    end
  end
end
