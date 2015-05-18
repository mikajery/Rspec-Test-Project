require 'rails_helper'

describe 'api/v1/email_templates/index', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'returns the email_templates' do
    email_templates = assign(:email_templates, FactoryGirl.create_list(:email_template, SpecMisc::MEDIUM_LIST_SIZE, :user => user))
    render
    email_templates_rendered = JSON.parse(rendered)

    expected_attributes = %w(category_uid uid name text html)

    email_templates.zip(email_templates_rendered).each do |email_template, email_template_rendered|
      spec_validate_attributes(expected_attributes, email_template, email_template_rendered)
    end
  end
end
