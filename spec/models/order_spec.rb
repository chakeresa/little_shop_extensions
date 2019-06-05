require 'rails_helper'

RSpec.describe Order, type: :model do

  describe 'validates' do
    it {should validate_presence_of :status}
    it {should validate_presence_of :address_id}
  end

  describe 'relationships' do
    it {should have_many :order_items}
    it {should have_many(:items).through(:order_items)}
    it {should belong_to :user}
    it {should belong_to(:address).optional}
  end

  describe "class methods" do
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

    it '::top_3_states shows shows the top 3 states where any orders were shipped (by number of orders), and count of orders' do
      top_3_states = ["KS", "CO", "IL"]
      top_3_states_order_counts = [4, 2, 1]

      actual_states = Order.top_3_states.map(&:state)
      expect(actual_states).to eq(top_3_states)

      actual_counts = Order.top_3_states.map(&:order_count)
      expect(actual_counts).to eq(top_3_states_order_counts)
    end

    it '::top_3_cities shows the top 3 city/state combos where any orders were shipped (by number of orders), and count of orders' do
      top_3_cities = ["Topeka", "Denver", "Springfield"]
      top_3_states = ["KS", "CO", "IL"]
      top_3_cities_order_counts = [3, 2, 1]

      actual_cities = Order.top_3_cities.map(&:city)
      expect(actual_cities).to eq(top_3_cities)

      actual_states = Order.top_3_cities.map(&:state)
      expect(actual_states).to eq(top_3_states)

      actual_counts = Order.top_3_cities.map(&:order_count)
      expect(actual_counts).to eq(top_3_cities_order_counts)
    end

    it '::top_3_by_quantity shows top 3 biggest orders by quantity of items shipped in an order, plus their quantities' do
      top_3_orders = [@order_2, @order_1, @order_6]
      top_3_order_quantities = [2200, 101, 5]

      expect(Order.top_3_by_quantity).to eq(top_3_orders)

      actual = Order.top_3_by_quantity.map(&:total_quantity)
      expect(actual).to eq(top_3_order_quantities)
    end

    it '::packaged_orders returns packaged orders' do
      expect(Order.packaged_orders).to eq([@order_5])
    end

    it '::pending_orders returns pending orders' do
      expect(Order.pending_orders).to eq([@order_3])
    end

    it '::shipped_orders returns shipped orders' do
      expect(Order.shipped_orders).to eq([@order_1, @order_2, @order_7, @order_9, @order_10, @order_8, @order_6 ])
    end

    it '::cancelled_orders returns cancelled orders' do
      expect(Order.cancelled_orders).to eq([@order_4])
    end
  end

  describe "instance methods" do
    before(:each) do
      @user = create(:user)
      @order_1 = create(:order, user: @user)
      @order_2 = create(:order, user: @user)

      @merchant = create(:merchant)
      @item_1 = create(:item, user: @merchant, price: 4.50)
      @item_2 = create(:item, user: @merchant, price: 2.33)
      @item_3 = create(:item, user: @merchant, price: 1.99)

      @oi_1 = create(:order_item, item: @item_1, order: @order_1, quantity: 3, price_per_item: @item_1.price)
      # note: in @oi_2 below, the price_per_item is intentionally different than the item's price, to make sure that the methods are using the price_per_item instead of the price in certain methods
      @oi_2 = create(:order_item, item: @item_2, order: @order_1, quantity: 1, price_per_item: @item_2.price - 0.33)

      @other_merchant = create(:merchant)
      @item_4 = create(:item, user: @other_merchant, price: 5.00)

      @oi_3 = create(:order_item, item: @item_4, order: @order_2, quantity: 2, price_per_item: 4.00)
      @oi_4 = create(:order_item, item: @item_3, order: @order_2, quantity: 1, price_per_item: @item_3.price + 1.01)
      @oi_5 = create(:order_item, item: @item_2, order: @order_2, quantity: 2, price_per_item: @item_2.price + 0.17)
    end

    it "#grand_total returns the total cost" do
      total_cost = @oi_1.price_per_item * @oi_1.quantity + @oi_2.price_per_item * @oi_2.quantity

      expect(@order_1.grand_total).to eq(total_cost)
    end

    it "#total_quantity returns the total count of all items' quantities" do
      expect(@order_1.total_quantity).to eq(@oi_1.quantity + @oi_2.quantity)
    end

    it "#item_price returns the purchase price for a particular item in the order" do
      expect(@order_1.item_price(@item_2)).to eq(@oi_2.price_per_item)
      expect(@order_1.item_price(@item_2)).to_not eq(@item_2.price)
      expect(@order_1.item_price(@item_3)).to eq(nil)
    end

    it "#item_quantity returns the quantity of a particular item in the order" do
      expect(@order_1.item_quantity(@item_2)).to eq(@oi_2.quantity)
      expect(@order_1.item_quantity(@item_3)).to eq(0)
    end

    it "#merchant_items returns items in a single order for a specific merchant" do
      expect(@order_2.merchant_items(@merchant)).to eq([@item_2, @item_3])
    end
  end

  describe 'more instance methods' do
    before :each do
      #create 2 pending orders and 1 shipped order.
      @user_1 = create(:user)
      @order_1 = create(:order, user: @user_1)
      @order_4 = create(:order, user: @user_1)

      @user_2 = create(:user)
      @order_2 = create(:order, user: @user_2)
      @order_3 = create(:shipped_order, user: @user_2)

      #create an item for another merchant that is part of one of our merchant's orders.
      @other_merchant = create(:merchant)
      @item_1 = create(:item, user: @other_merchant, price: 4.00)

      #items that are sold current merchant.
      @merchant = create(:merchant)
      @item_2 = create(:item, user: @merchant, price: 2.00)
      @item_3 = create(:item, user: @merchant, price: 1.00)

      #order1 with current merchant and other merchant's items.
      @oi_1 = create(:order_item, item: @item_1, order: @order_1, quantity: 2, price_per_item: @item_1.price)
      @oi_2 = create(:order_item, item: @item_2, order: @order_1, quantity: 3, price_per_item: @item_2.price)

      #order 2 with current merchant's items only.
      @oi_3 = create(:order_item, item: @item_2, order: @order_2, quantity: 4, price_per_item: @item_2.price)
      @oi_4 = create(:order_item, item: @item_3, order: @order_2, quantity: 5, price_per_item: @item_3.price - 0.25)

      #order 3 with shipped status for current merchant's item.
      @oi_5 = create(:order_item, item: @item_3, order: @order_3, quantity: 6, price_per_item: @item_3.price)

      #order 4 with only other merchant's items.
      @oi_6 = create(:order_item, item: @item_1, order: @order_4, quantity: 5, price_per_item: @item_1.price)
    end

    it "should return pending orders for a specific merchant's items in the orders" do
      pending_orders = [@order_1, @order_2]
      expect(Order.pending_merchant_orders(@merchant)).to eq(pending_orders)
    end

    it "should return total quantity of items for a specific merchant's items" do
      expect(@order_1.total_quantity_for_merchant(@merchant)).to eq(3)
      expect(@order_2.total_quantity_for_merchant(@merchant)).to eq(9)
    end

    it "should return total value of items in a specific merchant's order" do
      expect(@order_1.total_value_for_merchant(@merchant)).to eq(6)
      expect(@order_2.total_value_for_merchant(@merchant)).to eq(11.75)
    end

    it "#cancel cancels the order and its order_items" do
      order = create(:order)
      other_order = create(:order)
      order_item_1 = create(:fulfilled_order_item, order: order)
      order_item_2 = create(:order_item, order: order)
      order_item_3 = create(:fulfilled_order_item, order: other_order)

      order.cancel

      expect(order.reload.status).to eq("cancelled")
      expect(other_order.reload.status).to eq("pending")
      expect(order_item_1.reload.fulfilled).to eq(false)
      expect(order_item_2.reload.fulfilled).to eq(false)
      expect(order_item_3.reload.fulfilled).to eq(true)
    end
  end
end
