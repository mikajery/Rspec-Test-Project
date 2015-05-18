require 'rails_helper'

describe 'api/v1/gmail_labels/show', :type => :view do
  it 'should render the Gmail label' do
    gmail_label = assign(:gmail_label, FactoryGirl.create(:gmail_label))

    render

    gmail_label_rendered = JSON.parse(rendered)
    validate_gmail_label(gmail_label, gmail_label_rendered)
  end
end
