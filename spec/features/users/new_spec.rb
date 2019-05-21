require 'rails_helper'

RSpec.describe "User registration form" do
  it "can create new user" do
    visit root_path

    click_on 'Register'

    expect(current_path).to eq('/register')

    fill_in "user[name]", with: "Billy"
    fill_in "user[address]", with: "123 go to santa lane"
    fill_in "user[city]", with: "aurora"
    fill_in "user[state]", with: "colorado"
    fill_in "user[email]", with: "billyurrutia@gmail.com"
    fill_in "user[zip]", with: "123311"
    fill_in "user[password]", with: "1233"
    fill_in "user[password_confirmation]", with: "1233"

    click_on "Register User"

    expect(current_path).to eq('/profile')

    new_user = User.last

    expect(page).to have_content("Welcome, #{new_user.name}")
  end

  context "put in wrong confirmation password" do
    it 'brings you back to the register page' do
      visit root_path

      click_on 'Register'

      expect(current_path).to eq('/register')

      fill_in "user[name]", with: "Billy"
      fill_in "user[address]", with: "123 go to santa lane"
      fill_in "user[city]", with: "aurora"
      fill_in "user[state]", with: "colorado"
      fill_in "user[email]", with: "billyurrutia@gmail.com"
      fill_in "user[zip]", with: "123311"
      fill_in "user[password]", with: "1233"
      fill_in "user[password_confirmation]", with: "123"

      click_on "Register User"

      expect(current_path).to eq('/register')
      expect(page).to have_content("Failed to create account")
    end
  end
end
