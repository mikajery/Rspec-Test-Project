require 'rails_helper'

describe 'api/v1/email_template_categories/show', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'should render a email_template_category' do
    email_template_category = assign(:email_template_category, FactoryGirl.create(:email_template_category, :user => user))

    render

    email_template_category_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             name
                             created_at)

    expected_attributes_to_skip = %w(created_at)
    spec_validate_attributes(expected_attributes, email_template_category, email_template_category_rendered, expected_attributes_to_skip)
  end
end
