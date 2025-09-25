require 'rails_helper'

RSpec.describe "Account Management", type: :system do
  before do |example|
    if example.metadata[:js]
      driven_by(:selenium_chrome_headless)
    else
      driven_by(:rack_test)
    end
    ActionMailer::Base.deliveries.clear
  end
  let(:user) { create(:user) }
  let(:new_user) { build(:new_user) }

  describe "Account Management" do
    before do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
      visit edit_user_registration_path
    end

    it "does not allow updating email with invalid password" do
      fill_in "Email", with: new_user.email
      fill_in "Current password", with: new_user.password
      click_button "Update"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Current password is invalid")
      # expect(page).to have_css('input[name="user[current_password]"].input-error')
    end

    it "does not allow updating with invalid data" do
      fill_in "Email", with: ""
      fill_in "Password", with: "short"
      fill_in "Password confirmation", with: "different"
      fill_in "Current password", with: "different"
      click_button "Update"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content("Password confirmation doesn't match Password")
      expect(page).to have_content("Password is too short (minimum is 12 characters)")
      expect(page).to have_content("Current password is invalid")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      # expect(page).to have_css('input[name="user[password]"].input-error')
      # expect(page).to have_css('input[name="user[password_confirmation]"].input-error')
      # expect(page).to have_css('input[name="user[current_password]"].input-error')
    end

    it "allows updating email with valid password" do
      fill_in "Email", with: new_user.email
      fill_in "Current password", with: user.password
      click_button "Update"
      expect(page).to have_content("You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirmation link to confirm your new email address.")
      mail = ActionMailer::Base.deliveries.last
      confirmation_link = mail.body.encoded.match(/href="(?<url>.+?)"/)[:url]
      visit confirmation_link
      user.reload
      expect(user.reload.email).to eq(new_user.email)
    end

    it "allows updating new password with valid current password" do
      fill_in "Password", with: new_user.password
      fill_in "Password confirmation", with: new_user.password
      fill_in "Current password", with: user.password
      click_button "Update"
      expect(page).to have_content("Your account has been updated successfully")
      user.reload
      expect(user.valid_password?(new_user.password)).to be true
      expect(user.valid_password?(user.password)).to be false
    end
  end

  describe "Account Deletion" do
    pending("TODO: implement account deletion test")
    # it "allows user to delete their account", js: true do
    #   accept_confirm do
    #     click_button "Cancel my account"
    #   end
    #   expect(page).to have_content("Bye! Your account has been successfully cancelled")
    #   visit new_user_session_path
    #   fill_in "Email", with: user.email
    #   fill_in "Password", with: user.password
    #   click_button "Log in"
    #   expect(page).to have_content("Invalid Email or password")
    # end
  end
end
