require 'rails_helper'

RSpec.describe "User Login Workflow", type: :feature do
  scenario 'correct user login information entered' do
    user = create(:user)

    visit root_path
    click_on 'Login'

    expect(current_path).to eq(login_path)

    within('.login-form') do
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Login"
    end
    expect(current_path).to eq(profile_path)
    expect(page).to have_content("Welcome, #{user.name}!")
  end

  scenario 'incorrect user login password entered' do
    user = create(:user)

    visit login_path

    within('.login-form') do
      fill_in "Email", with: user.email
      fill_in "Password", with: 'wrongpassword'
      click_on "Login"
    end

    expect(current_path).to eq(login_path)
    expect(page).to have_content("Incorrect Username/Password Combination")
  end

  scenario 'incorrect user email entered' do
    visit login_path

    within('.login-form') do
      fill_in "Email", with: "stella@gmail.com"
      fill_in "Password", with: 'Password'
      click_on "Login"
    end

    expect(current_path).to eq(login_path)
    expect(page).to have_content("Incorrect Username/Password Combination")
  end

  scenario 'admin user logs in' do
    admin = create(:admin)

    visit login_path

    within('.login-form') do
      fill_in "Email", with: admin.email
      fill_in "Password", with: admin.password
      click_on "Login"
    end

    expect(current_path).to eq(root_path)
    expect(page).to have_content("Welcome, #{admin.name}!")
  end

  scenario 'merchant user logs in' do
    merchant = create(:merchant)

    visit login_path

    within('.login-form') do
      fill_in "Email", with: merchant.email
      fill_in "Password", with: merchant.password
      click_on "Login"
    end

    expect(current_path).to eq(merchant_dashboard_path)
    expect(page).to have_content("Welcome, #{merchant.name}!")
  end

  scenario 'a merchant with a disabled account will not be allowed to log in' do
    active_merchant = create(:merchant)
    disabled_merchant = create(:inactive_merchant)

    visit login_path

    fill_in :email, with: disabled_merchant.email
    fill_in :password, with: disabled_merchant.password

    click_button "Login"

    expect(page).to have_content("Your account has been disabled")
    expect(page).to_not have_content("Logged in as")
  end
end
