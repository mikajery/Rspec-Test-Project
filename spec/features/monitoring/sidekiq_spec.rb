require 'rails_helper'

describe 'Sidekiq monitoring', type: :feature do
  before { capybara_signin_user(user) }

  context 'signed admin' do
    let(:user) { FactoryGirl.create(:user, admin: true) }
    before { visit monitoring_sidekiq_web_path }

    it 'see monitoring' do
      expect(page).to have_content('Sidekiq idle')
    end

    it 'see back link' do
      expect(page).to have_link('Back to App')
    end
  end

  context 'signed regular user' do
    let(:user) { FactoryGirl.create(:user, admin: false) }
    before {  }

    it "can't see monitoring" do
      expect {
        visit monitoring_sidekiq_web_path
      }.to raise_exception(ActionController::RoutingError)
    end
  end
end
