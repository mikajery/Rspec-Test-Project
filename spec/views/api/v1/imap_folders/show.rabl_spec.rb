require 'rails_helper'

describe 'api/v1/imap_folders/show', :type => :view do
  it 'should render the IMAP Folder' do
    imap_folder = assign(:imap_folder, FactoryGirl.create(:imap_folder))

    render

    imap_folder_rendered = JSON.parse(rendered)
    validate_imap_folder(imap_folder, imap_folder_rendered)
  end
end
