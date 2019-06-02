require 'rails_helper'

RSpec.describe "as an admin user", type: :feature do
  context "when I visit the merchant index page and click on a merchant's name" do
    before(:each) do
      @admin = create(:admin)
      @user = create(:user)
      @merchant = create(:merchant)
      @address = create(:address, user: @merchant)
      @merchant.update!(primary_address_id: @address.id)

      @order = create(:order, user: @user)
      @item = create(:item, user: @merchant, price: 2.00)
      @order_item = create(:order_item, item: @item, order: @order, quantity: 2, price_per_item: @item.price)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
    end

    it "displays everything that a merchant would see" do
      visit merchants_path

      click_on(@merchant.name)

      expect(current_path).to eq(admin_merchant_path(@merchant))

      within "#merchant-profile" do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content(@merchant.email)
        expect(page).to have_content(@merchant.primary_address.street)
        expect(page).to have_content(@merchant.primary_address.city)
        expect(page).to have_content(@merchant.primary_address.state)
        expect(page).to have_content(@merchant.primary_address.zip)
      end

      within "#pending-merchant-orders-#{@order.id}" do
        expect(page).to have_link("Order #{@order.id}")
        expect(page).to have_content("Date Ordered: #{Date.strptime(@order.created_at.to_s)}")
        expect(page).to have_content("Total Quantity Ordered: #{@order.total_quantity_for_merchant(@merchant)}")
        expect(page).to have_content("Total Amount Owed: #{number_to_currency(@order.total_value_for_merchant(@merchant))}")
      end
    end

    it "when I visit a user's merchant page I'm redirected to the user profile page" do
      visit admin_merchant_path(@user)

      expect(current_path).to eq(admin_user_path(@user))
    end

    it "when I visit a merchant's user page I'm redirected to the merchant page" do
      visit admin_user_path(@merchant)

      expect(current_path).to eq(admin_merchant_path(@merchant))
    end
  end
end
