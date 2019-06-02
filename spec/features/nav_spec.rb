require 'rails_helper'

RSpec.describe "navigation bar", type: :feature do
  context "as a visitor" do
    it 'has working links' do
      visit items_path

      within("nav") do
        click_link "Home"
        expect(current_path).to eq(root_path)

        click_link "Browse All Items"
        expect(current_path).to eq(items_path)

        click_link "Browse All Merchants"
        expect(current_path).to eq(merchants_path)

        click_link "My Cart"
        expect(current_path).to eq(cart_path)

        click_link "Login"
        expect(current_path).to eq(login_path)

        click_link "Register"
        expect(current_path).to eq(register_path)

        expect(page).to_not have_link "My Profile"
        expect(page).to_not have_link "Log Out"
        expect(page).to_not have_link "Users"
        expect(page).to_not have_content "Logged in as"
      end
    end

    it "Next to the shopping cart link I see a count of the items in my cart" do
      item_1 = create(:item)
      item_2 = create(:item)

      visit items_path

      within("nav") do
        expect(page).to have_content("0")
      end

      click_link item_1.name
      click_button "Add to Cart"

      within("nav") do
        expect(page).to have_content("1")
      end

      click_link item_2.name
      click_button "Add to Cart"

      within("nav") do
        expect(page).to have_content("2")
      end

      click_link item_1.name
      click_button "Add to Cart"

      within("nav") do
        expect(page).to have_content("3")
      end
    end
  end

  context "as a user" do
    before(:each) do
      @user = create(:user)
    end

    it 'has working links' do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
      .and_return(@user)

      visit items_path

      within("nav") do
        click_link "Home"
        expect(current_path).to eq(root_path)

        click_link "Browse All Items"
        expect(current_path).to eq(items_path)

        click_link "Browse All Merchants"
        expect(current_path).to eq(merchants_path)

        click_link "My Cart"
        expect(current_path).to eq(cart_path)

        expect(page).to_not have_link("Login")
        expect(page).to_not have_link("Register")
        expect(page).to_not have_link("Users")

        click_link "My Profile"
        expect(current_path).to eq(profile_path)

        expect(page).to have_content "Logged in as #{@user.name}"
      end
    end

    it "has a working log out link" do
      visit login_path

      within('.login-form') do
        fill_in "Email", with: @user.email
        fill_in "Password", with: @user.password
        click_on "Login"
      end

      within("nav") do
        click_link "Log Out"

        expect(current_path).to eq(root_path)
        expect(page).to_not have_content "Logged in as"
      end
    end

    it "Next to the shopping cart link I see a count of the items in my cart" do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
        .and_return(@user)

      item_1 = create(:item)
      item_2 = create(:item)

      visit items_path

      within("nav") do
        expect(page).to have_content("0")
      end

      click_link item_1.name
      click_button "Add to Cart"

      within("nav") do
        expect(page).to have_content("1")
      end

      click_link item_2.name
      click_button "Add to Cart"

      within("nav") do
        expect(page).to have_content("2")
      end

      click_link item_1.name
      click_button "Add to Cart"

      within("nav") do
        expect(page).to have_content("3")
      end
    end
  end

  context "as a merchant user" do
    before(:each) do
      @merchant = create(:merchant)
    end

    it 'has working links' do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
      .and_return(@merchant)

      visit items_path

      within("nav") do
        click_link "Home"
        expect(current_path).to eq(root_path)

        click_link "Browse All Items"
        expect(current_path).to eq(items_path)

        click_link "Browse All Merchants"
        expect(current_path).to eq(merchants_path)

        expect(page).to_not have_link("My Cart")
        expect(page).to_not have_link("Login")
        expect(page).to_not have_link("Register")
        expect(page).to_not have_link("Users")

        click_link "Dashboard"
        expect(current_path).to eq(merchant_dashboard_path)

        expect(page).to have_content "Logged in as #{@merchant.name}"
      end
    end

    it "has a working log out link" do
      visit login_path

      within('.login-form') do
        fill_in "Email", with: @merchant.email
        fill_in "Password", with: @merchant.password
        click_on "Login"
      end

      within("nav") do
        click_link "Log Out"

        expect(current_path).to eq(root_path)
        expect(page).to_not have_content "Logged in as"
      end
    end
  end

  context "as an admin user" do
    before(:each) do
      @admin = create(:admin)
    end

    it 'has working links' do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
      .and_return(@admin)

      visit items_path

      within("nav") do
        click_link "Home"
        expect(current_path).to eq(root_path)

        click_link "Browse All Items"
        expect(current_path).to eq(items_path)

        click_link "Browse All Merchants"
        expect(current_path).to eq(merchants_path)

        expect(page).to_not have_link("My Cart")
        expect(page).to_not have_link("Login")
        expect(page).to_not have_link("Register")

        click_link "Dashboard"
        expect(current_path).to eq(admin_dashboard_path)

        expect(page).to have_content "Logged in as #{@admin.name}"
      end
    end

    it "has a link to view all users" do
      allow_any_instance_of(ApplicationController).to receive(:current_user)
      .and_return(@admin)

      visit items_path

      within("nav") do
        click_link "Users"
      end

      expect(current_path).to eq("/admin/users")
    end

    it "has a working log out link" do
      visit login_path

      within('.login-form') do
        fill_in "Email", with: @admin.email
        fill_in "Password", with: @admin.password
        click_on "Login"
      end

      within("nav") do
        click_link "Log Out"

        expect(current_path).to eq(root_path)
        expect(page).to_not have_content "Logged in as"
      end
    end
  end
end
