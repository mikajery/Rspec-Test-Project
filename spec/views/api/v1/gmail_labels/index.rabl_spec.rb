require 'rails_helper'

describe 'api/v1/gmail_labels/index', :type => :view do
  it 'should render the Gmail labels' do
    gmail_labels = assign(:gmail_labels, FactoryGirl.create_list(:gmail_label, SpecMisc::LARGE_LIST_SIZE))

    render

    gmail_labels_rendered = JSON.parse(rendered)

    gmail_labels.zip(gmail_labels_rendered).each do |gmail_label, gmail_label_rendered|
      validate_gmail_label(gmail_label, gmail_label_rendered)
    end
  end
end
