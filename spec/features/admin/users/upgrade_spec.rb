require 'rails_helper'

RSpec.describe "Upgrading a user", type: :feature do
  context "as a user" do
    before(:each) do
      @user = create(:user)
      create(:address, user: @user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "I don't see a button to upgrade my account" do
      visit profile_path

      expect(page).to_not have_content("Upgrade")
    end
  end

  context "as an admin" do
    before(:each) do
      @admin = create(:admin)
      create(:address, user: @admin)

      @user = create(:user)
      create(:address, user: @user)
    end

    it "I can upgrade a user to a merchant" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

      visit admin_user_path(@user)

      expect(current_path).to eq("/admin/users/#{@user.id}")

      click_button "Upgrade Account"

      expect(current_path).to eq("/admin/merchants/#{@user.id}")
      expect(page).to have_content("#{@user.name} has been upgraded to a merchant")

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user.reload)

      visit items_path

      expect(page).to_not have_content("My Cart")
      expect(page).to have_content("Dashboard")
    end
  end
end
