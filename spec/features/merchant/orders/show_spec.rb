require "rails_helper"
include ActionView::Helpers::TextHelper

RSpec.describe 'As a merchant: ' do
  describe "when I visit an order show page from my dashboard, " do
    before :each do
      @user = create(:user)
      address = create(:address, user: @user)
      @order_1 = create(:order, user: @user, address: address)
      @order_4 = create(:order, user: @user, address: address)

      @user_2 = create(:user)
      address_2 = create(:address, user: @user_2)
      @order_2 = create(:order, user: @user_2, address: address_2)
      @order_3 = create(:shipped_order, user: @user_2, address: address_2)

      #create an item for another merchant that is part of one of our merchant's orders.
      @other_merchant = create(:merchant)
      @item_1 = create(:item, user: @other_merchant, price: 4.00)

      #items that are sold by current merchant.
      @merchant = create(:merchant)
      @item_2 = create(:item, user: @merchant, price: 2.00, inventory: 10)
      @item_3 = create(:item, user: @merchant, price: 3.00)
      @item_4 = create(:item, user: @merchant, price: 4.00, inventory: 5)

      #order1 with current merchant and other merchant's items.
      @oi_1 = create(:order_item, item: @item_1, order: @order_1, quantity: 2, price_per_item: @item_1.price)
      @oi_2 = create(:order_item, item: @item_2, order: @order_1, quantity: 3, price_per_item: @item_2.price)

      #order 2 with current merchant's items only.
      @oi_3 = create(:order_item, item: @item_2, order: @order_2, quantity: 4, price_per_item: @item_2.price + 0.75)
      @oi_4 = create(:order_item, fulfilled: true, item: @item_3, order: @order_2, quantity: 5, price_per_item: @item_3.price - 0.25)
      @oi_5 = create(:order_item, item: @item_1, order: @order_2, quantity: 2, price_per_item: @item_1.price)
      @oi_6 = create(:order_item, item: @item_4, order: @order_2, quantity: 6, price_per_item: @item_4.price)

      #order 3 with shipped status for current merchant's item.
      @oi_7 = create(:order_item, item: @item_3, order: @order_3, quantity: 6, price_per_item: @item_2.price)

      #order 4 with only other merchant's items.
      @oi_8 = create(:order_item, item: @item_1, order: @order_4, quantity: 5, price_per_item: @item_1.price)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit merchant_order_path(@order_2)
    end

    it "if the user's desired quantity <= merchant's current inventory, I see a button to fulfill the item " do
      expect(page).to_not have_content(@item_1.name)

      within "#items-index-#{@item_2.id}" do
        expect(page).to have_content("Status: Not Fulfilled")
        expect(page).to have_button("Fulfill Item")
      end

      within "#items-index-#{@item_3.id}" do
        expect(page).to have_content("Status: Fulfilled")
        expect(page).to_not have_button("Fulfill Item")
      end

      within "#items-index-#{@item_4.id}" do
        expect(page).to have_content("Status: Not Fulfilled")
        expect(page).to_not have_button("Fulfill Item")
      end
    end

    it "I click on Fulfill Item, I am returned to the order show page, I see item is now fulfilled." do
      within "#items-index-#{@item_2.id}" do
        expect(page).to have_content("Status: Not Fulfilled")
        expect(page).to have_button("Fulfill Item")
        click_button "Fulfill Item"
        expect(current_path).to eq(merchant_order_path(@order_2))
        expect(page).to have_content("Status: Fulfilled")
      end
      expect(page).to have_content("The item was fulfilled")
    end

    it "displays a message if I don't have sufficient inventory to fulfill order" do
      within "#items-index-#{@item_4.id}" do
        expect(page).to have_content("Status: Not Fulfilled")
        expect(page).to_not have_button("Fulfill Item")
        expect(page).to have_content("You do not have sufficient inventory to fulfill this item.")
      end
    end
  end
end
