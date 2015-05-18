require "rails_helper"

describe "the signin page", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  context "when the email and password are correct" do
    it "should signin the user" do
      capybara_signin_user(user)

      visit "/"

      expect(page).to have_selector("#main")
    end
  end
end
