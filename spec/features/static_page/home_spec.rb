require "rails_helper"

describe "the home page", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  context "when the user is not signed in" do
    it "should have the correct links" do
      visit "/"

      expect(page).to have_link("Sign In")

      expect(page).to_not have_text(user.email)
    end
  end

  context "when the user is signed in" do
    before { capybara_signin_user(user) }

    it "should have the correct links" do
      visit "/"

      expect(page).to have_text(user.email)

      expect(page).to_not have_link("Sign In")
    end
  end
end
