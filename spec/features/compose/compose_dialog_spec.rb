require "rails_helper"

describe "compose dialog", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "when hidden" do
    it "should not be visible" do
      expect(page).to have_no_selector(".compose-modal")
    end
  end

  context "when opened" do
    let(:modal) { find(".compose-modal") }

    before { click_button("Compose") }

    it "should be visible" do
      expect(page).to have_selector(".compose-modal")
    end

    it "should be large by default" do
      expect(modal).to have_selector(".compose-modal-dialog-large")
    end

    it "should contain the to field by default" do
      expect(modal).to have_selector(".to-input")
    end

    it "should contain the subject field by default" do
      expect(modal).to have_selector(".subject-input")
    end

    it "should contain the compose toolbar by default" do
      expect(modal).to have_selector(".redactor-toolbar")
    end

    it "should contain the compose body field by default" do
      expect(modal).to have_selector(".redactor-editor")
    end

    it "should not contain cc field by default" do
      expect(modal).to have_no_selector(".cc-input")
    end

    it "should not contain bcc field by default" do
      expect(modal).to have_no_selector(".bcc-input")
    end

    it "should close on clicking x" do
      find(".compose-modal [data-dismiss]").click
      expect(page).to have_no_selector(".compose-modal")
    end

    it "should shrink on clicking resize button" do
      find(".compose-modal .compose-modal-size-toggle").click
      expect(modal).to have_selector(".compose-modal-dialog-small")
    end

    it "should contain cc field on clicking cc button" do
      find(".compose-modal .display-cc").click
      expect(modal).to have_selector(".cc-input")
    end

    it "should contain bcc field on clicking bcc button" do
      find(".compose-modal .display-bcc").click
      expect(modal).to have_selector(".bcc-input")
    end
  end
end
