require 'rails_helper'

RSpec.describe "Quotes", type: :system do
  before do
    driven_by(:rack_test)
  end
  # let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }
  let(:quote) { create(:quote) }
  let(:quote2) { create(:quote2) }

  describe "Accessing Quotes as a Non-Admin" do
    it "outputs the proper index page" do
      quote
      quote2

      visit quotes_url

      expect(current_path).to eq(quotes_path)
      expect(page).to have_selector("h1", text: "all quotes")
      expect(page).to have_content("This is an example quote.")
      expect(page).to have_content("This is the second example quote.")
      expect(page).to have_link("view detail", count: 2)
    end

    it "outputs the proper show pages" do
      quote
      quote2

      visit quote_url(quote)

      expect(current_path).to eq(quote_path(quote))
      expect(page).to have_selector("h1", text: "This is an example quote.")
      expect(page).to have_link("back")
      expect(page).to_not have_link("edit")
      expect(page).to_not have_link("delete")
      expect(quote.slug).to eq("this-is-an-example-quote")

      visit quote_url(quote2)

      expect(current_path).to eq(quote_path(quote2))
      expect(page).to have_selector("h1", text: "This is the second example quote.")
      expect(page).to have_content("This is a test description. It should be longer than a quote and explain more.")
      expect(page).to have_link("back")
      expect(page).to_not have_link("edit")
      expect(page).to_not have_link("delete")
      expect(quote2.slug).to eq("this-is-the-second-example-quote")
    end

    it "does not allow non-admin user to create new quote" do
      visit new_quote_url

      expect(page).to have_content("You need to sign in or sign up before continuing.")
      expect(current_path).to eq(new_user_session_path)
    end

    it "does not allow non-admin user to edit a quote" do
      quote

      visit edit_quote_url(quote)

      expect(page).to have_content("You need to sign in or sign up before continuing.")
      expect(current_path).to eq(new_user_session_path)
    end
  end

  describe "Accessing Quotes as an Admin" do
    it "outputs the proper index page" do
      quote
      quote2

      visit new_user_session_url
      fill_in "Email", with: admin_user.email
      fill_in "Password", with: admin_user.password
      click_button "Log in"

      expect(page).to have_content("successfully")

      visit quotes_path

      expect(current_path).to eq(quotes_path)
      expect(page).to have_selector("h1", text: "all quotes")
      expect(page).to have_selector("a", id: "new-quote")
      expect(page).to have_content("This is an example quote.")
      expect(page).to have_content("This is the second example quote.")
      expect(page).to have_link("view detail", count: 2)
    end

    it "outputs the proper show pages" do
      quote
      quote2

      visit new_user_session_url
      fill_in "Email", with: admin_user.email
      fill_in "Password", with: admin_user.password
      click_button "Log in"

      expect(page).to have_content("successfully")

      visit quote_url(quote)

      expect(current_path).to eq(quote_path(quote))
      expect(page).to have_selector("h1", text: "This is an example quote.")
      expect(page).to have_link("back")
      expect(page).to have_link("edit")
      expect(page).to have_link("delete")
      expect(quote.slug).to eq("this-is-an-example-quote")

      visit quote_url(quote2)

      expect(current_path).to eq(quote_path(quote2))
      expect(page).to have_selector("h1", text: "This is the second example quote.")
      expect(page).to have_content("This is a test description. It should be longer than a quote and explain more.")
      expect(page).to have_link("back")
      expect(page).to have_link("edit")
      expect(page).to have_link("delete")
      expect(quote2.slug).to eq("this-is-the-second-example-quote")
    end

    it "allows admin user to create new quote" do
      visit new_quote_path

      expect(page).to have_content("You need to sign in or sign up before continuing.")
      fill_in "Email", with: admin_user.email
      fill_in "Password", with: admin_user.password
      click_button "Log in"

      expect(page).to have_content("successfully")
      fill_in "quote_quote", with: "test quote"
      click_button "submit"
      expect(page).to have_content("created")
    end

    it "allows admin user to edit quote" do
      quote

      visit edit_quote_url(quote)

      expect(page).to have_content("You need to sign in or sign up before continuing.")
      fill_in "Email", with: admin_user.email
      fill_in "Password", with: admin_user.password
      click_button "Log in"

      expect(page).to have_content("successfully")
      expect(quote.slug).to eq("this-is-an-example-quote")
      fill_in "quote_quote", with: "test quote"
      fill_in "quote_rank", with: "2"
      fill_in "quote_description", with: "test description"
      click_button "submit"

      expect(page).to have_content("updated")
      expect(page).to have_selector("h1", text: "test quote")
      expect(page).to have_content("2")
      expect(page).to have_content("test description")
      quote.reload
      expect(quote.slug).to eq("test-quote")
    end

    pending("TODO: implement quote delete test")
    # it "allows admin user to delete quote" do
    #   quote

    #   visit new_user_session_url

    #   fill_in "Email", with: admin_user.email
    #   fill_in "Password", with: admin_user.password
    #   click_button "Log in"
    #   expect(page).to have_content("successfully")

    #   visit quote_path(quote)

    #   accept_confirm do
    #     click_button "delete"
    #   end

    #   expect(page).to have_content("successfully deleted")
    # end
  end
end
