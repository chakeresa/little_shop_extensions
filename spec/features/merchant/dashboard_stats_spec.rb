require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "When I visit my dashboard, I see an area with statistics" do
    before :each do
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
      create(:address, user: @merchant_1)
      @item_1 = create(:item, user: @merchant_1, inventory: 20)
      @item_2 = create(:item, user: @merchant_1, inventory: 20)
      @item_3 = create(:item, user: @merchant_1, inventory: 20)
      @item_4 = create(:item, user: @merchant_1, inventory: 20)
      @item_5 = create(:item, user: @merchant_1, inventory: 20)
      @item_6 = create(:item, user: @merchant_1, inventory: 20)
      @item_7 = create(:inactive_item, user: @merchant_1)

      @merchant_2 = create(:merchant)
      create(:address, user: @merchant_2)
      @item_8 = create(:item, user: @merchant_2)

      #shipped orders
      @order_1 = create(:shipped_order, user: @user_1, address: @addr_1)
      @order_2 = create(:shipped_order, user: @user_2, address: @addr_2)
      @order_3 = create(:shipped_order, user: @user_3, address: @addr_3)
      @order_4 = create(:shipped_order, user: @user_4, address: @addr_4)
      @order_5 = create(:shipped_order, user: @user_3, address: @addr_3)

      #pending order
      @order_6 = create(:order, user: @user_3, address: @addr_3)

      #cancelled order
      @order_7 = create(:cancelled_order, user: @user_1, address: @addr_1)

      #packaged order
      @order_8 = create(:packaged_order, user: @user_2, address: @addr_2)

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
    end

    it "displays top five items sold by quantity" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)
      visit merchant_dashboard_path

      within "#stats-top-five" do
        expect(page.all('li')[0]).to have_content("#{@item_2.name}, Quantity: #{@merchant_1.top_five_items[0].total_sold}")
        expect(page.all('li')[1]).to have_content("#{@item_5.name}, Quantity: #{@merchant_1.top_five_items[1].total_sold}")
        expect(page.all('li')[2]).to have_content("#{@item_3.name}, Quantity: #{@merchant_1.top_five_items[2].total_sold}")
        expect(page.all('li')[3]).to have_content("#{@item_4.name}, Quantity: #{@merchant_1.top_five_items[3].total_sold}")
        expect(page.all('li')[4]).to have_content("#{@item_6.name}, Quantity: #{@merchant_1.top_five_items[4].total_sold}")
      end
    end

    it "displays total items sold and inventory ratio" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)
      visit merchant_dashboard_path

      expect(page).to have_content("Sold #{@merchant_1.total_sold} item(s), which is #{number_to_percentage(@merchant_1.inventory_ratio, precision: 0)} of your total inventory")
    end

    it "displays top 3 states with their quantities" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit merchant_dashboard_path

      states  = ["CO", "CA", "IA"]
      quantities = [19, 12, 7]

      within ".top-3-states" do
        expect(page.all('li')[0]).to have_content("#{states[0]}, Quantity: #{quantities[0]}")
        expect(page.all('li')[1]).to have_content("#{states[1]}, Quantity: #{quantities[1]}")
        expect(page.all('li')[2]).to have_content("#{states[2]}, Quantity: #{quantities[2]}")
      end
    end

    it "displays top 3 city/states with their quantities" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit merchant_dashboard_path

      cities = ["Glendale", "Glendale", "Golden"]
      states = ["CA", "CO", "CO"]
      quantities = [12, 10, 9]

      within ".top-3-cities" do
        expect(page.all('li')[0]).to have_content("#{cities[0]}, #{states[0]}, Quantity: #{quantities[0]}")
        expect(page.all('li')[1]).to have_content("#{cities[1]}, #{states[1]}, Quantity: #{quantities[1]}")
        expect(page.all('li')[2]).to have_content("#{cities[2]}, #{states[2]}, Quantity: #{quantities[2]}")
      end
    end

    it "displays top user with most orders and number of orders" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit merchant_dashboard_path

      within ".top-user-with-most-orders" do
        expect(page).to have_content("#{@user_3.name}, Order Count: 2")
      end
    end

    it "displays user with the most total items and the total quantity" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit merchant_dashboard_path

      within ".top-user-with-most-items" do
        expect(page).to have_content("#{@user_3.name}, Item Count: 12")
      end
    end

    it "displays top 3 users with most money spent and the total" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit merchant_dashboard_path

      within ".top-user-with-most-money" do
        expect(page.all('li')[0]).to have_content("#{@user_3.name}, Total Money Spent: #{number_to_currency(1200)}")
        expect(page.all('li')[1]).to have_content("#{@user_1.name}, Total Money Spent: #{number_to_currency(1000)}")
        expect(page.all('li')[2]).to have_content("#{@user_4.name}, Total Money Spent: #{number_to_currency(900)}")
      end
    end
  end
end
