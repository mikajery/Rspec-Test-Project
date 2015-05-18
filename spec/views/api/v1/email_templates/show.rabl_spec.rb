require 'rails_helper'

describe 'api/v1/email_templates/show', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'should render a email_template' do
    email_template = assign(:email_template, FactoryGirl.create(:email_template, :user => user))


    render

    email_template_rendered = JSON.parse(rendered)

    expected_attributes = %w(category_uid
                             uid
                             name
                             text
                             html)

    spec_validate_attributes(expected_attributes, email_template, email_template_rendered)
  end
end
