require 'rails_helper'

describe 'api/v1/people/show', :type => :view do
  it 'should render a person' do
    person = assign(:person, FactoryGirl.create(:person))

    render

    person_rendered = JSON.parse(rendered)

    expected_attributes = %w(email_address name)

    spec_validate_attributes(expected_attributes, person, person_rendered)
  end
end
