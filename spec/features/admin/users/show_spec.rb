require 'rails_helper'

RSpec.describe "admin user profile page", type: :feature do
  before :each do
    @admin = create(:admin)
    @user = create(:user)
    @addr_1 = create(:address, user: @user)
    @addr_2 = create(:address, user: @user)
    @merchant = create(:merchant)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
  end

  it "displays the same information the user would see themselves" do
    visit admin_user_path(@user)

    within "#user-profile-#{@user.id}" do
      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.email)

      within "#address-#{@addr_1.id}" do
        expect(page).to have_content(@addr_1.nickname)
        expect(page).to have_content(@addr_1.street)
        expect(page).to have_content(@addr_1.city)
        expect(page).to have_content(@addr_1.state)
        expect(page).to have_content(@addr_1.zip)
      end

      within "#address-#{@addr_2.id}" do
        expect(page).to have_content(@addr_2.nickname)
        expect(page).to have_content(@addr_2.street)
        expect(page).to have_content(@addr_2.city)
        expect(page).to have_content(@addr_2.state)
        expect(page).to have_content(@addr_2.zip)
      end

      expect(page).to_not have_content(@user.password)
      expect(page).to_not have_link("Edit My Profile or Password")
    end
  end
end
