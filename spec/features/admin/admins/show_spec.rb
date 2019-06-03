require 'rails_helper'

RSpec.describe "As an admin user" do
  context "When I log into my dashboard" do
    before :each do
      @admin = create(:admin)
      @user_1 = create(:user)
      @addr_1 = create(:address, user: @user_1, city: "Glendale", state: "CO")
      @user_1.update(primary_address: @addr_1)

      @user_2 = create(:user)
      @addr_2 = create(:address, user: @user_2, city: "Glendale", state: "IA")
      @user_2.update(primary_address: @addr_2)

      @user_3 = create(:user)
      @addr_3 = create(:address, user: @user_3, city: "Glendale", state: "CA")
      @user_3.update(primary_address: @addr_3)

      @user_4 = create(:user)
      @addr_4 = create(:address, user: @user_4, city: "Golden", state: "CO")
      @user_4.update(primary_address: @addr_4)

      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, inventory: 20)
      @item_2 = create(:item, user: @merchant_1, inventory: 20)
      @item_3 = create(:item, user: @merchant_1, inventory: 20)
      @item_4 = create(:item, user: @merchant_1, inventory: 20)
      @item_5 = create(:item, user: @merchant_1, inventory: 20)
      @item_6 = create(:item, user: @merchant_1, inventory: 20)
      @item_7 = create(:inactive_item, user: @merchant_1)

      @merchant_2 = create(:merchant)
      @item_8 = create(:item, user: @merchant_2)

      #shipped orders
      @order_1 = create(:shipped_order, user: @user_1)
      @order_2 = create(:shipped_order, user: @user_2)
      @order_3 = create(:shipped_order, user: @user_3)
      @order_4 = create(:shipped_order, user: @user_4)
      @order_5 = create(:shipped_order, user: @user_3)

      #pending order
      @order_6 = create(:order, user: @user_3)

      #cancelled order
      @order_7 = create(:cancelled_order, user: @user_1)

      #packaged order
      @order_8 = create(:packaged_order, user: @user_2)

      #shipped orders
      @order_item_1 = create(:fulfilled_order_item, item: @item_1, quantity: 2, order: @order_1, price_per_item: 100)
      @order_item_2 = create(:fulfilled_order_item, item: @item_2, quantity: 7, order: @order_2, price_per_item: 100)
      @order_item_3 = create(:fulfilled_order_item, item: @item_5, quantity: 10, order: @order_3, price_per_item: 100)
      @order_item_4 = create(:fulfilled_order_item, item: @item_4, quantity: 5, order: @order_4, price_per_item: 100)
      @order_item_5 = create(:fulfilled_order_item, item: @item_3, quantity: 4, order: @order_4, price_per_item: 100)
      @order_item_6 = create(:fulfilled_order_item, item: @item_3, quantity: 2, order: @order_5, price_per_item: 100)

      @order_item_13 = create(:fulfilled_order_item, item: @item_2, quantity: 5, order: @order_1, price_per_item: 100)
      @order_item_14 = create(:fulfilled_order_item, item: @item_6, quantity: 3, order: @order_1, price_per_item: 100)
      @order_item_15 = create(:fulfilled_order_item, item: @item_8, quantity: 18, order: @order_1, price_per_item: 100)

      #not shipped orders
      @order_item_7 = create(:order_item, item: @item_1, order: @order_6, price_per_item: 100)
      @order_item_8 = create(:order_item, item: @item_1, order: @order_7, price_per_item: 100)
      @order_item_9 = create(:order_item, item: @item_1, order: @order_8, price_per_item: 100)

      @order_item_10 = create(:fulfilled_order_item, item: @item_2, order: @order_6, price_per_item: 100)
      @order_item_11 = create(:fulfilled_order_item, item: @item_2, order: @order_7, price_per_item: 100)
      @order_item_12 = create(:fulfilled_order_item, item: @item_2, order: @order_8, price_per_item: 100)

      #include previously active item that were shipped. Item is now inactive.
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
    end

    context "I see any 'packaged' orders ready to ship" do
      it "displays a button to 'Ship' the order, next to each order I see" do

        visit admin_dashboard_path

        within "#order-id-#{@order_8.id}" do
          expect(page).to have_button("Ship")
        end

        within "#packaged-orders" do
          expect(page).to_not have_content(@order_1.id)
        end
      end
    end

    context "When I click the 'Ship' button for an order" do
      it "the status of that order changes to 'shipped'" do
        visit admin_dashboard_path

        within "#order-id-#{@order_8.id}" do
          click_button "Ship"
          @order_8.reload

          expect(@order_8.shipped?).to eq(true)
        end

        expect(page).to have_content("#{@order_8.id} has been shipped!")
      end
    end

    it 'should display all orders and correct info' do
      admin = create(:admin)
      user_w_order_1 = create(:user)
      user_w_order_2 = create(:user)
      user_w_order_3 = create(:user)
      user_w_order_4 = create(:user)
      order_1 = create(:packaged_order, user: user_w_order_1)
      order_2 = create(:order, user: user_w_order_2)
      order_3 = create(:shipped_order, user: user_w_order_3)
      order_4 = create(:cancelled_order, user: user_w_order_4)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit admin_dashboard_path

      expect(page.all(".orders-index")[0]).to have_link(order_1.user.name)
      expect(page.all(".orders-index")[0]).to have_content(Date.strptime(order_1.created_at.to_s))
      expect(page.all(".orders-index")[0]).to have_content(order_1.id)
      expect(page.all(".orders-index")[0]).to have_content(order_1.status)

      expect(page.all(".orders-index")[1]).to have_link(order_2.user.name)
      expect(page.all(".orders-index")[1]).to have_content(Date.strptime(order_2.created_at.to_s))
      expect(page.all(".orders-index")[1]).to have_content(order_2.id)
      expect(page.all(".orders-index")[1]).to have_content(order_2.status)

      expect(page.all(".orders-index")[2]).to have_link(order_3.user.name)
      expect(page.all(".orders-index")[2]).to have_content(Date.strptime(order_3.created_at.to_s))
      expect(page.all(".orders-index")[2]).to have_content(order_3.id)
      expect(page.all(".orders-index")[2]).to have_content(order_3.status)

      expect(page.all(".orders-index")[3]).to have_link(order_4.user.name)
      expect(page.all(".orders-index")[3]).to have_content(Date.strptime(order_4.created_at.to_s))
      expect(page.all(".orders-index")[3]).to have_content(order_4.id)
      expect(page.all(".orders-index")[3]).to have_content(order_4.status)
    end
  end
end
