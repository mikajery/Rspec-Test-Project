require 'rails_helper'

describe 'api/v1/email_template_categories/index', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'returns the email_template_categories' do
    email_template_categories = assign(:email_template_categories, FactoryGirl.create_list(:email_template_category, SpecMisc::MEDIUM_LIST_SIZE, :user => user))
    render
    email_template_categories_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid name email_templates_count created_at)

    expected_attributes_to_skip = %w(created_at)
    email_template_categories.zip(email_template_categories_rendered).each do |email_template_category, email_template_category_rendered|
      spec_validate_attributes(expected_attributes, email_template_category, email_template_category_rendered, expected_attributes_to_skip)
    end
  end
end
