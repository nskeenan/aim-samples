require 'rails_helper'

RSpec.describe "Authentication", type: :system do
  before do
    driven_by(:rack_test)
    ActionMailer::Base.deliveries.clear
  end
  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }
  let(:new_user) { build(:new_user) }

  describe "User registration" do
    it "allows signing up with valid data" do
      visit new_user_registration_path
      fill_in "Email", with: new_user.email
      fill_in "Password", with: new_user.password
      fill_in "Password confirmation", with: new_user.password
      click_button "Sign up"
      expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
      expect(page).to have_current_path(root_path)
      mail = ActionMailer::Base.deliveries.last
      confirmation_link = mail.body.encoded.match(/href="(?<url>.+?)"/)[:url]
      visit confirmation_link
      expect(page).to have_content("Your email address has been successfully confirmed.")
      expect(page).to have_current_path(new_user_session_path)
      fill_in "Email", with: new_user.email
      fill_in "Password", with: new_user.password
      click_button "Log in"
      expect(page).to have_content("Signed in successfully.")
      expect(page).to have_current_path(root_path)
      expect(user.admin).to be false
    end

    it "does not allow signing up with existing email address" do
      visit new_user_registration_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      fill_in "Password confirmation", with: user.password
      click_button "Sign up"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email has already been taken")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      expect(page).to have_current_path(user_registration_path)
    end

    it "does not allow signing up with invalid data" do
      visit new_user_registration_path
      fill_in "Email", with: ""
      fill_in "Password", with: "short"
      fill_in "Password confirmation", with: "different"
      click_button "Sign up"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content("Password is too short (minimum is 12 characters)")
      expect(page).to have_content("Password confirmation doesn't match Password")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      # expect(page).to have_css('input[name="user[password]"].input-error')
      # expect(page).to have_css('input[name="user[password_confirmation]"].input-error')
      expect(page).to have_current_path(user_registration_path)
    end
  end

  describe "User login/logout" do
    it "allows logging in with valid credentials" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
      expect(page).to have_content("Signed in successfully.")
      expect(page).to have_current_path(root_path)
    end

    it "does not allow logging in with invalid credentials" do
      visit new_user_session_path
      fill_in "Email", with: new_user.email
      fill_in "Password", with: new_user.password
      click_button "Log in"
      expect(page).to have_content("Invalid Email or password.")
      expect(page).to have_current_path(user_session_path)
    end

    it "logs out a user" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
      expect(page).to have_content("Signed in successfully.")
      visit destroy_user_session_path
      expect(page).to have_content("Signed out successfully.")
      expect(page).to have_current_path(root_path)
    end
  end

  describe "User password reset" do
    it "allows resetting password for an existing user" do
      visit new_user_password_path
      fill_in "Email", with: user.email
      click_button "reset password"
      expect(page).to have_content("You will receive an email with instructions on how to reset your password in a few minutes.")
      expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
      expect(page).to have_current_path(new_user_session_path)
      mail = ActionMailer::Base.deliveries.last
      reset_link = mail.body.encoded.match(/href="(?<url>.+?)"/)[:url]
      visit reset_link
      fill_in "new password", with: new_user.password
      fill_in "confirm new password", with: new_user.password
      click_button "Change my password"
      expect(page).to have_content("Your password has been changed successfully")
      expect(page).to have_current_path(root_path)
    end

    it "does not allow resetting password with blank email" do
      visit new_user_password_path
      fill_in "Email", with: ""
      click_button "reset password"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email can't be blank")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      expect(page).to have_current_path(user_password_path)
    end

    it "does not allow resetting password with unknown email" do
      visit new_user_password_path
      fill_in "Email", with: new_user.email
      click_button "reset password"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email not found")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      expect(page).to have_current_path(user_password_path)
    end
  end

  describe "User unlock" do
    it "locks the user after too many failed login attempts" do
      max_attempts = Devise.maximum_attempts || 10

      max_attempts.times do
        visit new_user_session_path
        fill_in "Email", with: user.email
        fill_in "Password", with: new_user.password
        click_button "Log in"
      end

      user.reload
      expect(user.access_locked?).to be true
      expect(page).to have_content("Your account is locked.")
      expect(page).to have_current_path(new_user_session_path)
    end

    it "does not allow logging in when account is locked" do
      user.lock_access!
      expect(user.access_locked?).to be true
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
      expect(page).to have_content("Your account is locked.")
      expect(page).to have_current_path(new_user_session_path)
      expect(user.access_locked?).to be true
    end

    it "does not allow requesting an account unlock with blank email" do
      visit new_user_unlock_path
      fill_in "Email", with: ""
      click_button "Resend"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email can't be blank")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      expect(page).to have_current_path(user_unlock_path)
    end

    it "does not allow requesting account unlock when account isn't locked" do
      visit new_user_unlock_path
      fill_in "Email", with: user.email
      click_button "Resend"
      expect(page).to have_content("prohibited this user from being saved")
      expect(page).to have_content("Email was not locked")
      # expect(page).to have_css('input[name="user[email]"].input-error')
      expect(page).to have_current_path(user_unlock_path)
    end

    it "allows unlocking account with valid credentials" do
      user.lock_access!
      expect(user.access_locked?).to be true
      visit new_user_unlock_path
      fill_in "Email", with: user.email
      click_button "Resend"
      expect(page).to have_content("You will receive an email with instructions for how to unlock your account in a few minutes.")
      mail = ActionMailer::Base.deliveries.last
      unlock_link = mail.body.encoded.match(/href="(?<url>.+?)"/)[:url]
      visit unlock_link
      expect(page).to have_content("Your account has been unlocked successfully. Please sign in to continue.")
      expect(page).to have_current_path(new_user_session_path)
      user.reload
      expect(user.access_locked?).to be false
    end
  end

  describe "Access Control" do
    it "redirects unauthenticated user from protected page" do
      visit edit_user_registration_path
      expect(page).to have_content("You need to sign in or sign up before continuing")
      expect(page).to have_current_path(new_user_session_path)
    end

    it "allows authenticated user to access protected page" do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
      visit edit_user_registration_path
      expect(page).to have_content("edit user")
      expect(page).to have_current_path(edit_user_registration_path)
    end
  end
end
