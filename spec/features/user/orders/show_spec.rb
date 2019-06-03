require 'rails_helper'

RSpec.describe "User Profile Order Show Page", type: :feature do
  context "as a registered user" do
    before(:each) do
      @user = create(:user)
      @address = create(:address, user: @user)
      @another_address = create(:address, user: @user)

      @merchant = create(:merchant)
      @merchant_address = create(:address, user: @merchant)

      @order = create(:order, user: @user, address: @address)
      @other_order = create(:order, user: @user, address: @another_address)
      @item_1 = create(:item, user: @merchant)
      @item_2 = create(:item, user: @merchant)
      @item_3 = create(:item, user: @merchant)
      @oi_1 = create(:order_item, item: @item_1, order: @order, quantity: 3, price_per_item: @item_1.price - 0.33)
      # Note: the order item above was intentionally changed so that the order_item's price_per_item does NOT match the item's price (to make sure the order is using the right one -- from the order_item, NOT the item)
      @oi_2 = create(:order_item, item: @item_3, order: @order, quantity: 1, price_per_item: @item_3.price)
      @oi_3 = create(:order_item, item: @item_2, order: @other_order, quantity: 5, price_per_item: @item_2.price)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it "shows information for a specific order" do
      visit user_orders_path
      click_link "Order #{@order.id}"

      expect(current_path).to eq(user_order_path(@order))

      within("h1") do
        expect(page).to have_content("Order #{@order.id}")
      end

      expect(page).to_not have_content("Order #{@other_order.id}")

      expect(page).to have_content("Placed on: #{@order.created_at}")
      expect(page).to have_content("Last Updated: #{@order.updated_at}")
      expect(page).to have_content("Status: #{@order.status}")
      expect(page).to have_content("Total Items Ordered: #{@oi_1.quantity + @oi_2.quantity}")
      expect(page).to have_content("Total Cost: #{number_to_currency(@order.grand_total)}")

      expect(page).to have_content(@address.nickname.titlecase)
      expect(page).to have_content(@address.street)
      expect(page).to have_content("#{@address.city}, #{@address.state}")
      expect(page).to have_content(@address.zip)
    end

    it "shows information for each item in the order" do
      visit user_order_path(@order)

      within("#item-#{@item_1.id}") do
        expect(page).to have_link(@item_1.name)
        expect(page).to have_content(@item_1.description)
        expect(page).to have_css("img[src*='#{@item_1.image}']")
        expect(page).to have_content("Price: #{number_to_currency(@oi_1.price_per_item)} each")
        expect(page).to have_content("Quantity: #{@oi_1.quantity}")
        expect(page).to have_content("Subtotal: #{number_to_currency(@order.item_subtotal(@item_1))}")
      end

      within("#item-#{@item_3.id}") do
        expect(page).to have_link(@item_3.name)
        expect(page).to have_content(@item_3.description)
        expect(page).to have_css("img[src*='#{@item_3.image}']")
        expect(page).to have_content("Price: #{number_to_currency(@oi_2.price_per_item)} each")
        expect(page).to have_content("Quantity: #{@oi_2.quantity}")
        expect(page).to have_content("Subtotal: #{number_to_currency(@order.item_subtotal(@item_3))}")
      end

      expect(page).to_not have_content(@item_2.name)
    end

    it "allows me to change the address for a pending order" do
      visit user_order_path(@order)

      find('#order_address_id').select(@another_address.street)
      click_button 'Change Shipping Address'

      expect(page).to have_content("Shipping address succcessfully changed")
      expect(page).to have_content(@another_address.nickname.titlecase)
      expect(page).to have_content(@another_address.street)
      expect(page).to have_content("#{@another_address.city}, #{@another_address.state}")
      expect(page).to have_content(@another_address.zip)
    end

    xit "does not allow me to change the address for a packaged order"
    xit "does not allow me to change the address for a shipped order"
    xit "does not allow me to change the address for a cancelled order"
    xit "does not allow me to change the address for a different user's pending order"
  end
end
