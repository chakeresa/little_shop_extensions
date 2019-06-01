require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it {should validate_presence_of :email}
    it {should validate_presence_of :role}
    it {should validate_presence_of :name}
    it {should validate_presence_of :email}
    it {should validate_presence_of :password_digest}
  end

  describe 'relationships' do
    it {should have_many :items}
    it {should have_many :orders}
    it {should have_many :addresses}
  end

  describe 'Class Methods' do
    describe '::active_merchants' do
      it 'should return all active merchants' do
        active_merchant_1 = create(:merchant)
        active_merchant_2 = create(:merchant)
        inactive_merchant = create(:inactive_merchant)
        regular_active_user = create(:user)
        active_admin = create(:admin)

        expect(User.active_merchants.order(:id)).to eq([active_merchant_1, active_merchant_2])
      end
    end

    describe '::inactive_merchants' do
      it 'should return all inactive (disabled) merchants' do
        active_merchant = create(:merchant)
        inactive_merchant_1 = create(:inactive_merchant)
        inactive_merchant_2 = create(:inactive_merchant)
        inactive_user = create(:inactive_user)

        expect(User.inactive_merchants.order(:id)).to eq([inactive_merchant_1, inactive_merchant_2])
      end
    end

    describe "statistics" do
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
        @user_1 = create(:user, city: "Springfield", state: "KS")

        @order_1 = create(:shipped_order, user: @user_1) # total_quantity = 101
        # merchant_1:
        @oi_1 = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 100, price_per_item: 0.50)
        # merchant_2:
        @oi_2 = create(:fulfilled_order_item, order: @order_1, item: @item_2, quantity: 1, price_per_item: 30.0)

        ####### @user_2
        @user_2 = create(:user, city: "Springfield", state: "IL")

        @order_2 = create(:shipped_order, user: @user_2) # total_quantity = 2200
        # merchant_1:
        @oi_7 = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 200, price_per_item: 0.05)
        # merchant_1:
        @oi_3 = create(:fulfilled_order_item, order: @order_2, item: @item_3, quantity: 2000, price_per_item: 100.0)

        ####### @user_3
        @user_3 = create(:user, city: "Topeka", state: "KS")

        @order_3 = create(:order, user: @user_3) # pending order
        # merchant_3 / pending order -- should not be included in stats for sales:
        @oi_4 = create(:fulfilled_order_item, order: @order_3, item: @item_4, quantity: 300, price_per_item: 20.0)

        @order_4 = create(:cancelled_order, user: @user_3)
        # merchant_3 / cancelled order -- should not be included in stats for sales:
        @oi_5 = create(:fulfilled_order_item, order: @order_4, item: @item_4, quantity: 400, price_per_item: 13.0)

        @order_5 = create(:packaged_order, user: @user_3)
        # merchant_3 / packaged order -- should not be included in stats for sales:
        @oi_6 = create(:fulfilled_order_item, order: @order_5, item: @item_5, quantity: 410, price_per_item: 25.0)

        @order_7 = create(:shipped_order, user: @user_3) # total_quantity = 1
        # merchant_2:
        @oi_9 = create(:fulfilled_order_item, order: @order_7, item: @item_2, quantity: 1, price_per_item: 1.0)

        @order_9 = create(:shipped_order, user: @user_3)
        @order_10 = create(:shipped_order, user: @user_3)

        ####### @user_4
        @user_4 = create(:user, city: "Denver", state: "CO")

        @order_8 = create(:shipped_order, user: @user_4) # total_quantity = 1
        # merchant_3:
        @oi_10 = create(:fulfilled_order_item, order: @order_8, item: @item_4, quantity: 1, price_per_item: 1.0)

        @order_6 = create(:shipped_order, user: @user_4) # total_quantity = 5
        # merchant_4:
        @oi_8 = create(:fulfilled_order_item, order: @order_6, item: @item_6, quantity: 5, price_per_item: 10000.0)
      end

      it '::top_3_by_revenue shows top 3 merchants who have sold the most by price, and their revenue' do
        top_3_merchants = [@merchant_4, @merchant_1, @merchant_2]
        top_3_revenues = [50000, 60, 31]

        expect(User.top_3_by_revenue).to eq(top_3_merchants)

        actual = User.top_3_by_revenue.map(&:total_revenue)
        expect(actual).to eq(top_3_revenues)
      end

      it '#total_revenue' do
        expect(@merchant_4.total_revenue).to eq(50000)
        expect(@merchant_1.total_revenue).to eq(60)
        expect(@merchant_2.total_revenue).to eq(31)

        merchant = create(:merchant)
        expect(merchant.total_revenue).to eq(0)
      end

      it '::top_3_merch_by_quantity shows top 3 merchants who have sold the most by quantity, and their quantities' do
        top_3_merchants = [@merchant_1, @merchant_4, @merchant_2]
        top_3_merchant_quantities = [300, 5, 2]

        expect(User.top_3_merch_by_quantity).to eq(top_3_merchants)

        actual = User.top_3_merch_by_quantity.map(&:total_quantity)
        expect(actual).to eq(top_3_merchant_quantities)
      end

      it '::top_3_states shows shows the top 3 states where any orders were shipped (by number of orders), and count of orders' do
        top_3_states = ["KS", "CO", "IL"]
        top_3_states_order_counts = [4, 2, 1]

        actual_states = User.top_3_states.map(&:state)
        expect(actual_states).to eq(top_3_states)

        actual_counts = User.top_3_states.map(&:order_count)
        expect(actual_counts).to eq(top_3_states_order_counts)
      end

      it '::top_3_cities shows the top 3 city/state combos where any orders were shipped (by number of orders), and count of orders' do
        top_3_cities = ["Topeka", "Denver", "Springfield"]
        top_3_states = ["KS", "CO", "IL"]
        top_3_cities_order_counts = [3, 2, 1]

        actual_cities = User.top_3_cities.map(&:city)
        expect(actual_cities).to eq(top_3_cities)

        actual_states = User.top_3_cities.map(&:state)
        expect(actual_states).to eq(top_3_states)

        actual_counts = User.top_3_cities.map(&:order_count)
        expect(actual_counts).to eq(top_3_cities_order_counts)
      end
    end

    describe "merchant speed stats" do
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

      it '::average_fulfillment_times returns the average_fulfillment_time for each merchant' do
        merchants = [@merchant_1, @merchant_2, @merchant_3, @merchant_4]
        avg_times = [2, 4, 1, 5]

        merchants_actual = User.average_fulfillment_times.order(:id)
        times_actual = User.average_fulfillment_times.order(:id).map do |merchant|
          merchant.avg_time.to_i
        end

        expect(merchants_actual).to eq(merchants)
        expect(times_actual).to eq(avg_times)
      end

      it '::fastest_3_merchants shows top 3 merchants who were fastest at fulfilling items in an order, and their times' do
        merchants = [@merchant_3, @merchant_1, @merchant_2]
        avg_times = [1, 2, 4]

        merchants_actual = User.fastest_3_merchants
        times_actual = User.fastest_3_merchants.map do |merchant|
          merchant.avg_time.to_i
        end

        expect(merchants_actual).to eq(merchants)
        expect(times_actual).to eq(avg_times)
      end

      it '::slowest_3_merchants shows worst 3 merchants who were slowest at fulfilling items in an order, and their times' do
        merchants = [@merchant_4, @merchant_2, @merchant_1]
        avg_times = [5, 4, 2]

        merchants_actual = User.slowest_3_merchants
        times_actual = User.slowest_3_merchants.map do |merchant|
          merchant.avg_time.to_i
        end

        expect(merchants_actual).to eq(merchants)
        expect(times_actual).to eq(avg_times)
      end
    end

    describe '::all_merchants' do
      it 'should return all merchants (active and disabled)' do
        user = create(:user)
        admin = create(:admin)

        active_merchant_1 = create(:merchant)
        active_merchant_2 = create(:merchant)

        inactive_merchant_1 = create(:inactive_merchant)

        all_merchants = [active_merchant_1, active_merchant_2, inactive_merchant_1]

        expect(User.all_merchants).to eq(all_merchants)
      end
    end

    describe '::regular_users' do
      it 'should return all regular users' do
        user_1 = create(:user)
        user_2 = create(:user)
        inactive_user = create(:inactive_user)
        active_merchant = create(:merchant)
        active_admin = create(:admin)

        expect(User.regular_users).to eq([user_1, user_2, inactive_user])
      end
    end
  end

  describe 'instance methods' do
    before :each do
      @user_1 = create(:user, city: "Glendale", state: "CO")
      @user_2 = create(:user, city: "Glendale", state: "IA")
      @user_3 = create(:user, city: "Glendale", state: "CA")
      @user_4 = create(:user, city: "Golden", state: "CO")

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
    end

    it "can find top five items by quantity" do
      top_five = [@item_2, @item_5, @item_3, @item_4, @item_6]
      expect(@merchant_1.top_five_items).to eq(top_five)
    end

    it "can calculate total quantities sold and inventory ratio" do
      total_sold = 38
      inventory_ratio = (38/120.0)*100
      expect(@merchant_1.total_sold).to eq(total_sold)
      expect(number_to_percentage(@merchant_1.inventory_ratio)).to eq(number_to_percentage(inventory_ratio))
    end

    it "calculates top 3 state where items were shipped and their quantities " do

      top_three_states = ["CO", "CA", "IA"]

      answer_1 = @merchant_1.top_three_states.map(&:state)

      expect(answer_1).to eq(top_three_states)

      top_three_quantities = [19, 12, 7]
      answer_2 = @merchant_1.top_three_states.map(&:total_quantity)

      expect(answer_2).to eq(top_three_quantities)
    end

    it "calculates top 3 city where items were shipped and their quantities " do

      top_three_cities = ["Glendale", "Glendale", "Golden"]
      top_three_states = ["CA", "CO", "CO"]
      quantities = [12, 10, 9]

      answer_1 = @merchant_1.top_three_cities.map(&:city)
      answer_2 = @merchant_1.top_three_cities.map(&:state)
      answer_3 = @merchant_1.top_three_cities.map(&:total_quantity)

      expect(answer_1).to eq(top_three_cities)
      expect(answer_2).to eq(top_three_states)
      expect(answer_3).to eq(quantities)
    end

    it 'calculates top user with most orders and their orders quantity' do
      expect(@merchant_1.top_user_orders).to eq(@user_3)
    end

    it 'calculates top user with most items and their items quantity' do
      expect(@merchant_1.top_user_items).to eq(@user_3)
    end

    it 'calculates top 3 users with most money spent and their totals' do
      expect(@merchant_1.top_3_spenders).to eq([@user_3, @user_1, @user_4])
    end

    it "#downgrade_to_regular_user changes a merchant to a regular user and disables their items" do
      @merchant_1.downgrade_to_regular_user

      expect(@merchant_1.reload.role).to eq("user")
      expect(@item_1.reload.active).to eq(false)
    end
  end
end
