require 'rails_helper'

RSpec.describe "User Registration form" do
  it "can create new user and their home address" do
    visit root_path

    click_on 'Register'

    expect(current_path).to eq('/register')

    name = "Billy"
    street = "123 go to santa lane"
    city = "aurora"
    state = "colorado"
    email = "billyurrutia@gmail.com"
    zip = "123311"
    password = "1233"


    fill_in "user[name]", with: name
    fill_in "user[addresses_attributes][0][street]", with: street
    fill_in "user[addresses_attributes][0][city]", with: city
    fill_in "user[addresses_attributes][0][state]", with: state
    fill_in "user[addresses_attributes][0][zip]", with: zip
    fill_in "user[email]", with: email
    fill_in "user[password]", with: password
    fill_in "user[password_confirmation]", with: password

    click_on "Register User"

    expect(current_path).to eq('/profile')

    new_user = User.last

    expect(page).to have_content("Welcome, #{name}")
    expect(new_user.name).to eq(name)
    expect(new_user.email).to eq(email)
    expect(new_user.primary_address.nickname).to eq("home")
    expect(new_user.primary_address.street).to eq(street)
    expect(new_user.primary_address.city).to eq(city)
    expect(new_user.primary_address.state).to eq(state)
    expect(new_user.primary_address.zip).to eq(zip)
  end

  context "put in wrong confirmation password" do
    it 'brings you back to the register page' do
      visit root_path

      click_on 'Register'

      expect(current_path).to eq('/register')

      fill_in "user[name]", with: "Billy"
      fill_in "user[email]", with: "billyurrutia@gmail.com"
      fill_in "user[addresses_attributes][0][street]", with: "123 go to santa lane"
      fill_in "user[addresses_attributes][0][city]", with: "aurora"
      fill_in "user[addresses_attributes][0][state]", with: "colorado"
      fill_in "user[addresses_attributes][0][zip]", with: "123311"
      fill_in "user[password]", with: "1233"
      fill_in "user[password_confirmation]", with: "123"

      click_on "Register User"

      expect(page).to have_content("Password confirmation doesn't match Password")
    end
  end

  context 'email in use already' do
    it 'gives flash error email in use' do
      User.create!(email: "ABC@gmail.com",
                  name: "billy",
                  city: "miami",
                  state: "colorado",
                  password: "123",
                  zip: "111",
                  address: "1233 s way")

      visit '/register'

      fill_in "user[name]", with: "Billy"
      fill_in "user[email]", with: "abc@gmail.com"
      fill_in "user[addresses_attributes][0][street]", with: "123 go to santa lane"
      fill_in "user[addresses_attributes][0][city]", with: "aurora"
      fill_in "user[addresses_attributes][0][state]", with: "colorado"
      fill_in "user[addresses_attributes][0][zip]", with: "123311"
      fill_in "user[password]", with: "1233"
      fill_in "user[password_confirmation]", with: "1233"

      click_on "Register User"

      expect(page).to have_content("Email has already been taken")

      fill_in 'user[email]', with: "abc123@gmail.com"
      fill_in "user[password]", with: "1233"
      fill_in "user[password_confirmation]", with: "1233"

      click_on "Register User"

      expect(current_path).to eq('/profile')

      new_user = User.last

      expect(page).to have_content("Welcome, #{new_user.name}")
      expect(new_user.primary_address.city).to eq("aurora")
    end
  end
end
