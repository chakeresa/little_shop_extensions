require "rails_helper"
include ActionView::Helpers::TextHelper

RSpec.describe 'As a merchant: ' do
  describe "when I visit my dashboard, " do
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

    it "I am taken to order show page from my dashboard where I see details about the order" do
      click_on "Order #{@order_2.id}"
      expect(current_path).to eq(merchant_order_path(@order_2))
      expect(page).to have_content(@order_2.id)
      expect(page).to have_content("Customer Name: #{@order_2.user.name}")
      expect(page).to have_content("Customer Address: #{@order_2.user.address}")
      expect(page).to have_content("Order Status: #{@order_2.status.titleize}")

      within "#items-index-#{@item_2.id}" do
        expect(page).to have_link(@item_2.name)
        expect(page).to have_css("img[src*='#{@item_2.image}']")
        expect(page).to have_content("Purchase Price: #{number_to_currency(@oi_3.price_per_item)}")
        expect(page).to have_content("Purchase Quantity: #{(@oi_3.quantity)}")
      end

      within "#items-index-#{@item_3.id}" do
        expect(page).to have_link(@item_3.name)
        expect(page).to have_css("img[src*='#{@item_3.image}']")
        expect(page).to have_content("Purchase Price: #{number_to_currency(@oi_4.price_per_item)}")
        expect(page).to have_content("Purchase Quantity: #{(@oi_4.quantity)}")
      end

      expect(page).to_not have_content(@item_1.name)
    end
  end
end
