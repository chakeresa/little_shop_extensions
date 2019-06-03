require 'rails_helper'

RSpec.describe 'As a merchant user: ' do
  describe 'I visit my dashboard, ' do
    before :each do
      @merchant = create(:merchant)
      address = create(:address, user: @merchant)
      @merchant.update!(primary_address_id: address.id)

      @other_merchant = create(:merchant)
    end

    it "displays my profile data" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit merchant_dashboard_path

      within "#dashboard-show" do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content(@merchant.email)
        expect(page).to have_content(@merchant.primary_address.street)
        expect(page).to have_content("#{@merchant.primary_address.city}, #{@merchant.primary_address.state}")
        expect(page).to have_content(@merchant.primary_address.zip)

        expect(page).to_not have_content(@other_merchant.name)
      end
    end

    it "has a link to see my bulk discounts" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit merchant_dashboard_path
      click_link "View my bulk discounts"

      expect(current_path).to eq(merchant_bulk_discounts_path)
    end
  end

  describe "when I have orders" do
    before :each do
      @user = create(:user)
      @order_1 = create(:order, user: @user)
      @order_4 = create(:order, user: @user)

      @user_2 = create(:user)
      @order_2 = create(:order, user: @user_2)
      @order_3 = create(:shipped_order, user: @user_2)

      #create an item for another merchant that is part of one of our merchant's orders.
      @other_merchant = create(:merchant)
      @item_1 = create(:item, user: @other_merchant, price: 4.00)

      #items that are sold by current merchant.
      @merchant = create(:merchant)
      @item_2 = create(:item, user: @merchant, price: 2.00)
      @item_3 = create(:item, user: @merchant, price: 1.00)

      #order1 with current merchant and other merchant's items.
      @oi_1 = create(:order_item, item: @item_1, order: @order_1, quantity: 2, price_per_item: @item_1.price)
      @oi_2 = create(:order_item, item: @item_2, order: @order_1, quantity: 3, price_per_item: @item_2.price)

      #order 2 with current merchant's items only.
      @oi_3 = create(:order_item, item: @item_2, order: @order_2, quantity: 4, price_per_item: @item_2.price + 0.75)
      @oi_4 = create(:order_item, item: @item_3, order: @order_2, quantity: 5, price_per_item: @item_3.price - 0.25)

      #order 3 with shipped status for current merchant's item.
      @oi_5 = create(:order_item, item: @item_3, order: @order_3, quantity: 6, price_per_item: @item_2.price)

      #order 4 with only other merchant's items.
      @oi_6 = create(:order_item, item: @item_1, order: @order_4, quantity: 5, price_per_item: @item_1.price)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit merchant_dashboard_path
    end

    it "I see a list of pending orders with only items I sell" do
      expect(page).to have_content("Orders")

      within "#merchant-orders-#{@order_1.id}" do
        expect(page).to have_link("Order #{@order_1.id}")
        expect(page).to have_content("Date Ordered: #{Date.strptime(@order_1.created_at.to_s)}")
        expect(page).to have_content("Total Quantity Ordered: #{@order_1.total_quantity_for_merchant(@merchant)}")
        expect(page).to have_content("Total Amount Owed: #{number_to_currency(@order_1.total_value_for_merchant(@merchant))}")
      end

      within "#merchant-orders-#{@order_2.id}" do
        expect(page).to have_link("Order #{@order_2.id}")
        expect(page).to have_content("Date Ordered: #{Date.strptime(@order_2.created_at.to_s)}")
        expect(page).to have_content("Total Quantity Ordered: #{@order_2.total_quantity_for_merchant(@merchant)}")
        expect(page).to have_content("Total Amount Owed: #{number_to_currency(@order_2.total_value_for_merchant(@merchant))}")
      end

      expect(page).to_not have_content(@order_3.id)
    end

    it "has a link to the order show page" do
      click_on "Order #{@order_2.id}"
      expect(current_path).to eq(merchant_order_path(@order_2))
    end
  end
end
