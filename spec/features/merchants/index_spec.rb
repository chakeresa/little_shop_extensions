require 'rails_helper'

RSpec.describe "Merchant Index", type: :feature do
  context "as a visitor" do
    it 'should display all active merchants' do
      active_merchant_1 = create(:merchant)
      am1_address = create(:address, user: active_merchant_1)
      active_merchant_2 = create(:merchant)
      am2_address = create(:address, user: active_merchant_2)
      inactive_merchant = create(:inactive_merchant)
      im_address = create(:address, user: inactive_merchant)

      visit merchants_path

      within("#merchant-id-#{active_merchant_1.id}") do
        expect(page).to have_content(active_merchant_1.name)
        expect(page).to have_content(am1_address.city)
        expect(page).to have_content(am1_address.state)
        expect(page).to have_content(Date.strptime(active_merchant_1.created_at.to_s))
      end
      within("#merchant-id-#{active_merchant_2.id}") do
        expect(page).to have_content(active_merchant_2.name)
        expect(page).to have_content(am2_address.city)
        expect(page).to have_content(am2_address.state)
        expect(page).to have_content(Date.strptime(active_merchant_2.created_at.to_s))
      end

      expect(page).to_not have_content(inactive_merchant.name)
      expect(page).to_not have_content(im_address.city)
      expect(page).to_not have_content(im_address.state)
    end
  end

  context "as an admin user" do
    before(:each) do
      @admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                  .and_return(@admin)

      @active_merchant = create(:merchant)
      @am_address = create(:address, user: @active_merchant)
      @disabled_merchant = create(:inactive_merchant)
      @dm_address = create(:address, user: @disabled_merchant)
    end

    it "shows all merchants - even inactive ones" do
      visit merchants_path

      expect(current_path).to eq("/merchants")

      within("#merchant-id-#{@active_merchant.id}") do
        expect(page).to have_link(@active_merchant.name)
        expect(page).to have_content(@am_address.city)
        expect(page).to have_content(@am_address.state)
      end

      within("#merchant-id-#{@disabled_merchant.id}") do
        expect(page).to have_link(@disabled_merchant.name)
        expect(page).to have_content(@dm_address.city)
        expect(page).to have_content(@dm_address.state)
      end
    end

    it "has links to all merchant dashboards" do
      visit merchants_path
      click_link(@active_merchant.name)
      expect(current_path).to eq("/admin/merchants/#{@active_merchant.id}")

      visit merchants_path
      click_link(@disabled_merchant.name)
      expect(current_path).to eq("/admin/merchants/#{@disabled_merchant.id}")
    end

    it "has buttons to enable/disable merchants" do
      visit merchants_path

      within("#merchant-id-#{@active_merchant.id}") do
        expect(page).to have_button("Disable Merchant")
        expect(page).to_not have_button("Enable Merchant")
      end

      within("#merchant-id-#{@disabled_merchant.id}") do
        expect(page).to_not have_button("Disable Merchant")
        expect(page).to have_button("Enable Merchant")
      end
    end

    it "when I click on a 'Disable Merchant' button, it displays a flash message that the merchant's account is now disabled" do
      visit admin_merchants_path

      within("#merchant-id-#{@active_merchant.id}") do
        expect(page).to_not have_button("Enable Merchant")
        click_button "Disable Merchant"
        expect(current_path).to eq(admin_merchants_path)
      end

      expect(page).to have_content("#{@active_merchant.name}'s account is now disabled.")
    end

    it "when I click on a 'Enable Merchant' button, it displays a flash message that the merchant's account is now enabled" do
      visit admin_merchants_path

      within("#merchant-id-#{@disabled_merchant.id}") do
        expect(page).to_not have_button("Disable Merchant")
        click_button "Enable Merchant"
        expect(current_path).to eq(admin_merchants_path)
      end

      expect(page).to have_content("#{@disabled_merchant.name}'s account is now enabled.")
    end
  end
end
