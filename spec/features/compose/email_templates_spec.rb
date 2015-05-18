require "rails_helper"

describe "email templates menu", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:email_template_attrs) { FactoryGirl.attributes_for(:email_template) }
  let(:email_template) { FactoryGirl.create(:email_template, user: user) }
  let(:menu) { find(".email-templates") }
  let(:modal) { find(".compose-modal") }

  before with_templates: true do
    email_template
  end

  before do
    capybara_signin_user(user)
    click_on("Compose")
  end

  before with_content: true do
    find(".compose-modal .redactor-editor").set(email_template_attrs[:html])
  end

  before do
    within(".compose-modal") do
      click_on("Templates")
    end
  end

  context "with no templates" do
    it "should not contain template items" do
      expect(menu).to have_no_selector(".load-email-template")
    end

    it "should not contain remove button" do
      expect(menu).to have_no_selector(".update-email-template")
    end

    it "should not contain update button" do
      expect(menu).to have_no_selector(".delete-email-template")
    end
  end

  context "with templates", with_templates: true do
    it "should contain template items" do
      expect(menu).to have_selector(".load-email-template")
    end

    it "should not contain remove button" do
      expect(menu).to have_selector(".update-email-template")
    end

    it "should not contain update button" do
      expect(menu).to have_selector(".delete-email-template")
    end
  end

  context "when creating template", with_content: true do
    before do
      find(".compose-modal .create-email-template").click

      # Workaround for Selenium, but maybe a real bug in FF
      find(".ui-dialog-titlebar-close").click
      within(".compose-modal") do
        click_on("Templates")
        find(".create-email-template").click
      end
      # end of workaround

      within(".create-email-templates-dialog") do
        find(".email-template-name").set(email_template_attrs[:name])
        click_on("Create")
      end
    end

    it "should display success message" do
      expect(page).
        to have_text("You have successfully created an email template!")
    end

    it "should contain template item" do
      within(".compose-modal") do
        click_on("Templates")
      end
      expect(menu).to have_text(email_template_attrs[:name])
    end
  end

  context "when using template", with_templates: true do
    before { find(".load-email-template").click }

    it "should update content" do
      expect(modal).to have_text(email_template.html)
    end
  end

  context "when updating template", with_templates: true, with_content: true do
    before do
      find(".update-email-template").click

      within(".update-email-templates-dialog") do
        click_on("Update")
      end
    end

    it "should update content" do
      expect(page).
        to have_text("You have successfully updated an email template!")
    end
  end

  context "when deleting template", with_templates: true do
    before do
      find(".delete-email-template").click

      within(".delete-email-templates-dialog") do
        click_on("Delete")
      end
    end

    it "should display success message" do
      expect(page).
        to have_text("You have successfully deleted an email template!")
    end

    it "should not contain template item" do
      within(".compose-modal") do
        click_on("Templates")
      end
      expect(menu).to have_no_text(email_template_attrs[:name])
    end
  end
end
