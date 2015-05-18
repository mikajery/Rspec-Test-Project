require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  describe '#page_title' do
    context "for given page title" do
      it 'returns the appended page title to the default title' do
        expect(helper.page_title('Test')).to eq("#{$config.service_name} | Test")
      end
    end

    context "for no given page title" do
      it 'returns the default title' do
        expect(helper.page_title).to eq($config.service_name)
      end
    end
  end
end
