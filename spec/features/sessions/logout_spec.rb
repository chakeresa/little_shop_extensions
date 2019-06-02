require 'rails_helper'

RSpec.describe "User logout, " do
  it "can log out A USER who is logged in" do
    user = create(:user)

    visit login_path

    within(".login-form") do
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Login"
    end


    expect(current_path).to eq(profile_path)

    click_link "Log Out"

    expect(current_path).to eq(root_path)
    expect(page).to have_content("You are logged out!")
    expect(page).to have_link("Login")
    expect(page).to have_link("Register")
    expect(page).to_not have_link("Log Out")
  end

  it "can log out AN ADMIN who is logged in" do
    admin = create(:admin)

    visit login_path

    within(".login-form") do
      fill_in "Email", with: admin.email
      fill_in "Password", with: admin.password
      click_on "Login"
    end

    expect(current_path).to eq(root_path)

    click_link "Log Out"

    expect(current_path).to eq(root_path)
    expect(page).to have_content("You are logged out!")
    expect(page).to have_link("Login")
    expect(page).to have_link("Register")
    expect(page).to_not have_link("Log Out")
  end

  it "can log out A MERCHANT who is logged in" do
    merchant = create(:merchant)
    address = create(:address, user: merchant)

    visit login_path

    within(".login-form") do
      fill_in "Email", with: merchant.email
      fill_in "Password", with: merchant.password
      click_on "Login"
    end

    expect(current_path).to eq(merchant_dashboard_path)

    click_link "Log Out"

    expect(current_path).to eq(root_path)
    expect(page).to have_content("You are logged out!")
    expect(page).to have_link("Login")
    expect(page).to have_link("Register")
    expect(page).to_not have_link("Log Out")
  end

  it 'empties cart on logout' do
    merchant = create(:merchant)
    user = create(:user)
    item_1 = create(:item, user: merchant)

    visit login_path

    within(".login-form") do
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Login"
    end

    visit item_path(item_1)

    click_on "Add to Cart"

    expect(current_path).to eq(items_path)
    expect(page).to have_content("Cart: 1")

    click_on "Log Out"

    expect(current_path).to eq(root_path)
    expect(page).to have_content("Cart: 0")
  end
end
