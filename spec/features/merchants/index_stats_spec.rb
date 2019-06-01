require 'rails_helper'

RSpec.describe "Merchant Index Statistics", type: :feature do
  context "as a visitor - most stats" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1)

      @merchant_2 = create(:merchant)
      @item_2 = create(:item, user: @merchant_2)

      @merchant_3 = create(:merchant)
      @item_4 = create(:item, user: @merchant_3)
      @item_5 = create(:item, user: @merchant_3)

      @merchant_4 = create(:merchant)
      @item_6 = create(:item, user: @merchant_4)

      @merchant_5 = create(:inactive_merchant) # should not be included in stats
      @item_3 = create(:item, user: @merchant_5)

      ####### @user_1
      @user_1 = create(:user)
      @addr_1 = create(:address, user: @user_1, city: "Springfield", state: "KS")
      @user_1.update(primary_address: @addr_1)

      @order_1 = create(:shipped_order, user: @user_1, address: @addr_1) # total_quantity = 101
      # merchant_1:
      @oi_1 = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 100, price_per_item: 0.50)
      # merchant_2:
      @oi_2 = create(:fulfilled_order_item, order: @order_1, item: @item_2, quantity: 1, price_per_item: 30.0)

      ####### @user_2
      @user_2 = create(:user)
      @addr_2 = create(:address, user: @user_2, city: "Springfield", state: "IL")
      @user_2.update(primary_address: @addr_2)

      @order_2 = create(:shipped_order, user: @user_2, address: @addr_2) # total_quantity = 2200
      # merchant_1:
      @oi_7 = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 200, price_per_item: 0.05)
      # merchant_1:
      @oi_3 = create(:fulfilled_order_item, order: @order_2, item: @item_3, quantity: 2000, price_per_item: 100.0)

      ####### @user_3
      @user_3 = create(:user)
      @addr_3 = create(:address, user: @user_3, city: "Topeka", state: "KS")
      @user_3.update(primary_address: @addr_3)

      @order_3 = create(:order, user: @user_3, address: @addr_3) # pending order
      # merchant_3 / pending order -- should not be included in stats for sales:
      @oi_4 = create(:fulfilled_order_item, order: @order_3, item: @item_4, quantity: 300, price_per_item: 20.0)

      @order_4 = create(:cancelled_order, user: @user_3, address: @addr_3)
      # merchant_3 / cancelled order -- should not be included in stats for sales:
      @oi_5 = create(:fulfilled_order_item, order: @order_4, item: @item_4, quantity: 400, price_per_item: 13.0)

      @order_5 = create(:packaged_order, user: @user_3, address: @addr_3)
      # merchant_3 / packaged order -- should not be included in stats for sales:
      @oi_6 = create(:fulfilled_order_item, order: @order_5, item: @item_5, quantity: 410, price_per_item: 25.0)

      @order_7 = create(:shipped_order, user: @user_3, address: @addr_3) # total_quantity = 1
      # merchant_2:
      @oi_9 = create(:fulfilled_order_item, order: @order_7, item: @item_2, quantity: 1, price_per_item: 1.0)

      @order_9 = create(:shipped_order, user: @user_3, address: @addr_3)
      @order_10 = create(:shipped_order, user: @user_3, address: @addr_3)

      ####### @user_4
      @user_4 = create(:user)
      @addr_4 = create(:address, user: @user_4, city: "Denver", state: "CO")
      @user_4.update(primary_address: @addr_4)

      @order_8 = create(:shipped_order, user: @user_4, address: @addr_4) # total_quantity = 1
      # merchant_3:
      @oi_10 = create(:fulfilled_order_item, order: @order_8, item: @item_4, quantity: 1, price_per_item: 1.0)

      @order_6 = create(:shipped_order, user: @user_4, address: @addr_4) # total_quantity = 5
      # merchant_4:
      @oi_8 = create(:fulfilled_order_item, order: @order_6, item: @item_6, quantity: 5, price_per_item: 10000.0)
    end

    it 'shows top 3 merchants who have sold the most by price, and their revenue' do
      visit merchants_path

      within("#statistics") do
        within("#top-3-merchants-by-revenue") do
          expect(page.all("li")[0]).to have_content("#{@merchant_4.name}: #{number_to_currency(@merchant_4.total_revenue)}")
          expect(page.all("li")[1]).to have_content("#{@merchant_1.name}: #{number_to_currency(@merchant_1.total_revenue)}")
          expect(page.all("li")[2]).to have_content("#{@merchant_2.name}: #{number_to_currency(@merchant_2.total_revenue)}")
        end
      end
    end

    it 'shows top 3 merchants who have sold the most by quantity, and their revenue' do
      visit merchants_path

      within("#statistics") do
        within("#top-3-merchants-by-quantity") do
          expect(page.all("li")[0]).to have_content("#{@merchant_1.name}: #{number_to_currency(@merchant_1.total_revenue)}")
          expect(page.all("li")[1]).to have_content("#{@merchant_4.name}: #{number_to_currency(@merchant_4.total_revenue)}")
          expect(page.all("li")[2]).to have_content("#{@merchant_2.name}: #{number_to_currency(@merchant_2.total_revenue)}")
        end
      end
    end

    it 'shows top 3 biggest orders by quantity of items shipped in an order, plus their quantities' do
      visit merchants_path

      within("#statistics") do
        within("#top-3-orders-by-quantity") do
          expect(page.all("li")[0]).to have_content("Order #{@order_2.id}: #{@order_2.total_quantity}")
          expect(page.all("li")[1]).to have_content("Order #{@order_1.id}: #{@order_1.total_quantity}")
          expect(page.all("li")[2]).to have_content("Order #{@order_6.id}: #{@order_6.total_quantity}")
        end
      end
    end

    it 'shows top 3 states where any orders were shipped (by number of orders), and count of orders' do
      visit merchants_path

      within("#statistics") do
        within("#top-3-states") do
          expect(page.all("li")[0]).to have_content("KS: 4 order(s)")
          expect(page.all("li")[1]).to have_content("CO: 2 order(s)")
          expect(page.all("li")[2]).to have_content("IL: 1 order(s)")
        end
      end
    end

    it 'shows top 3 cities where any orders were shipped (by number of orders, also Springfield, MI should not be grouped with Springfield, CO), and the count of orders' do
      visit merchants_path

      within("#statistics") do
        within("#top-3-cities") do
          expect(page.all("li")[0]).to have_content("Topeka, KS: 3 order(s)")
          expect(page.all("li")[1]).to have_content("Denver, CO: 2 order(s)")
          expect(page.all("li")[2]).to have_content("Springfield, IL: 1 order(s)")
        end
      end
    end
  end

  context "as a visitor - merchant fulfillment speed stats" do
    before(:each) do
      @merchant_1 = create(:merchant) # avg_time = 2 days
      @item_1 = create(:item, user: @merchant_1)
      @order_item_1 = create(:fulfilled_order_item, item: @item_1, created_at: 3.days.ago, updated_at: 1.days.ago)
      @order_item_2 = create(:fulfilled_order_item, item: @item_1, created_at: 2.days.ago, updated_at: 1.days.ago)
      @order_item_3 = create(:fulfilled_order_item, item: @item_1, created_at: 4.days.ago, updated_at: 1.days.ago)

      @merchant_2 = create(:merchant) # avg_time = 4 days
      @item_2 = create(:item, user: @merchant_2)
      @order_item_4 = create(:fulfilled_order_item, item: @item_2, created_at: 5.days.ago, updated_at: 1.days.ago)

      @merchant_3 = create(:merchant) # avg_time = 1 day
      @item_3 = create(:item, user: @merchant_3)
      @order_item_5 = create(:fulfilled_order_item, item: @item_3, created_at: 2.days.ago, updated_at: 1.days.ago)

      @merchant_4 = create(:merchant) # avg_time = 5 days
      @item_4 = create(:item, user: @merchant_4)
      @order_item_6 = create(:fulfilled_order_item, item: @item_4, created_at: 6.days.ago, updated_at: 1.days.ago)

      @merchant_5 = create(:merchant) # no fulfilled order_items
      @item_5 = create(:item, user: @merchant_5)
      @order_item_6 = create(:order_item, item: @item_5, created_at: 1.days.ago, updated_at: 1.days.ago)
    end

    it 'shows top 3 merchants who were fastest at fulfilling items in an order, and their times' do
      visit merchants_path

      within("#statistics") do
        within("#3-fastest-merchants") do
          expect(page.all("li")[0]).to have_content("#{@merchant_3.name}: 1 day(s)")
          expect(page.all("li")[1]).to have_content("#{@merchant_1.name}: 2 day(s)")
          expect(page.all("li")[2]).to have_content("#{@merchant_2.name}: 4 day(s)")
        end
      end
    end

    it 'shows worst 3 merchants who were slowest at fulfilling items in an order, and their times' do
      visit merchants_path

      within("#statistics") do
        within("#3-slowest-merchants") do
          expect(page.all("li")[0]).to have_content("#{@merchant_4.name}: 5 day(s)")
          expect(page.all("li")[1]).to have_content("#{@merchant_2.name}: 4 day(s)")
          expect(page.all("li")[2]).to have_content("#{@merchant_1.name}: 2 day(s)")
        end
      end
    end
  end
end