require 'rails_helper'

RSpec.describe Item, type: :model do

  describe 'validates' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :price}
    it {should validate_presence_of :description}
    it {should validate_presence_of :inventory}

    it {should validate_numericality_of(:price).is_greater_than_or_equal_to(0.01)}
    it {should validate_numericality_of(:inventory).only_integer}
    it {should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0)}
  end

  describe 'relationships' do
    it {should belong_to :user}
    it {should have_many(:orders).through(:order_items)}
  end

  describe 'class methods' do
    before :each do
      @merchant_1 = create(:merchant)
      @item_1 = @merchant_1.items.create!(name: 'Item 1', active: true, price: 1.00, description: 'Stuff 1', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 1)
      @item_2 = @merchant_1.items.create!(name: 'Item 2', active: true, price: 2.00, description: 'Stuff 2', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 2)
      @item_5 = @merchant_1.items.create!(name: 'Item 5', active: false, price: 5.00, description: 'Stuff 5', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 5)


      @merchant_2 = create(:merchant)
      @item_3 = @merchant_2.items.create!(name: 'Item 3', active: true, price: 3.00, description: 'Stuff 3', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 3)
      @item_4 = @merchant_2.items.create!(name: 'Item 4', active: false, price: 4.00, description: 'Stuff 4', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 4)
    end

    it "can filter active items only" do
      expect(Item.active_items).to eq([@item_1, @item_2, @item_3])
    end

    it "can filter the most/least popular items by quantity purchased" do
      merchant = create(:merchant)

      user_1 = create(:user)
      user_2 = create(:user)
      user_3 = create(:user)

      item_1 = create(:item, user: merchant, inventory: 20)
      item_2 = create(:item, user: merchant, inventory: 20)
      item_3 = create(:item, user: merchant, inventory: 20)
      item_4 = create(:item, user: merchant, inventory: 20)
      item_5 = create(:item, user: merchant, inventory: 20)
      item_6 = create(:item, user: merchant, inventory: 20)

      order_1 = create(:shipped_order, user: user_1)
      order_2 = create(:shipped_order, user: user_2)
      order_3 = create(:shipped_order, user: user_3)
      order_4 = create(:shipped_order, user: user_1)
      order_5 = create(:shipped_order, user: user_1)
      order_6 = create(:shipped_order, user: user_2)
      order_7 = create(:cancelled_order, user: user_2)
      order_8 = create(:order, user: user_2)

      order_items_1 = create(:fulfilled_order_item, item: item_1, order: order_1, quantity: 100)
      order_items_2 = create(:fulfilled_order_item, item: item_2 , order: order_2, quantity: 99)
      order_items_3 = create(:fulfilled_order_item, item: item_3, order: order_3 , quantity: 98)
      order_items_4 = create(:fulfilled_order_item, item: item_4 , order: order_4, quantity: 97)
      order_items_5 = create(:order_item, item: item_5, order: order_5, quantity: 96)
      order_items_6 = create(:order_item, item: item_3, order: order_6, quantity: 95)
      order_items_7 = create(:order_item, item: item_6, order: order_7, quantity: 101)
      order_items_8 = create(:order_item, item: item_6, order: order_8, quantity: 102)

      expect(Item.sort_by_popularity(3, :desc)).to eq([item_1, item_2, item_3])
      expect(Item.sort_by_popularity(3, :asc)).to eq([item_4, item_3, item_2])
    end
  end

  describe "instance methods" do
    it "can calculate average fulfillment time per item" do
      merchant_1 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      order_item_1 = create(:fulfilled_order_item, item: item_1, created_at: 3.days.ago, updated_at: 1.days.ago)
      order_item_2 = create(:fulfilled_order_item, item: item_1, created_at: 2.days.ago, updated_at: 1.days.ago)
      order_item_3 = create(:fulfilled_order_item, item: item_1, created_at: 4.days.ago, updated_at: 1.days.ago)
      # not fulfilled: should not be included
      order_item_4 = create(:order_item, item: item_1, created_at: 1.days.ago, updated_at: 1.days.ago)

      expect(item_1.average_fulfillment_time).to eq(2)

      item_2 = create(:item, user: merchant_1)
      expect(item_2.average_fulfillment_time).to eq(nil)
    end

    it "#order_count returns how many orders include that item" do
      never_ordered_item = create(:item)

      ordered_item = create(:item)
      order_1 = create(:order)
      oi_1 = create(:order_item, order: order_1, item: ordered_item)
      order_2 = create(:packaged_order)
      oi_2 = create(:order_item, order: order_2, item: ordered_item)
      order_3 = create(:shipped_order)
      oi_3 = create(:fulfilled_order_item, order: order_3, item: ordered_item)
      order_4 = create(:cancelled_order)
      oi_4 = create(:order_item, order: order_4, item: ordered_item)

      disabled_ordered_item = create(:inactive_item)
      order_5 = create(:order)
      oi_5 = create(:order_item, order: order_5, item: disabled_ordered_item)
      order_6 = create(:packaged_order)
      oi_6 = create(:fulfilled_order_item, order: order_6, item: disabled_ordered_item)

      expect(never_ordered_item.order_count).to eq(0)
      expect(ordered_item.order_count).to eq(4)
      expect(disabled_ordered_item.order_count).to eq(2)
    end

    it "#purchase_price finds price_per_item for an item, #purchase_quantity finds quantity of item sold in an order" do
      user = create(:user)
      order_1 = create(:order, user: user)
      order_2 = create(:order, user: user)

      other_merchant = create(:merchant)
      item_1 = create(:item, user: other_merchant, price: 1.00)

      merchant = create(:merchant)
      item_2 = create(:item, user: merchant, price: 2.00)
      item_3 = create(:item, user: merchant, price: 3.00)

      oi_1 = create(:order_item, item: item_1, order: order_1, quantity: 2, price_per_item: item_1.price)
      oi_2 = create(:order_item, item: item_2, order: order_1, quantity: 3, price_per_item: item_2.price + 0.75)

      oi_3 = create(:order_item, item: item_2, order: order_2, quantity: 4, price_per_item: item_2.price + 0.25)
      oi_4 = create(:order_item, item: item_3, order: order_2, quantity: 5, price_per_item: item_3.price + 0.20)

      expect(item_2.purchase_price(order_1)).to eq(oi_2.price_per_item)
      expect(item_2.purchase_price(order_2)).to eq(oi_3.price_per_item)

      expect(item_2.purchase_quantity(order_1)).to eq(oi_2.quantity)
      expect(item_2.purchase_quantity(order_2)).to eq(oi_3.quantity)
    end

    it "#item_fulfilled? returns true/false for fulfilled, #sufficient_inventory? returns true/false" do
      user = create(:user)
      order_1 = create(:order, user: user)
      order_4 = create(:order, user: user)

      user_2 = create(:user)
      order_2 = create(:order, user: user_2)
      order_3 = create(:shipped_order, user: user_2)

      #create an item for another merchant that is part of one of our merchant's orders.
      other_merchant = create(:merchant)
      item_1 = create(:item, user: other_merchant, price: 4.00)

      #items that are sold by current merchant.
      merchant = create(:merchant)
      item_2 = create(:item, user: merchant, price: 2.00, inventory: 10)
      item_3 = create(:item, user: merchant, price: 3.00)
      item_4 = create(:item, user: merchant, price: 4.00, inventory: 5)

      #order1 with current merchant and other merchant's items.
      oi_1 = create(:order_item, item: item_1, order: order_1, quantity: 2, price_per_item: item_1.price)
      oi_2 = create(:order_item, item: item_2, order: order_1, quantity: 3, price_per_item: item_2.price)

      #order 2 with current merchant's items only.
      oi_3 = create(:order_item, item: item_2, order: order_2, quantity: 4, price_per_item: item_2.price + 0.75)
      oi_4 = create(:order_item, fulfilled: true, item: item_3, order: order_2, quantity: 5, price_per_item: item_3.price - 0.25)
      oi_5 = create(:order_item, item: item_1, order: order_2, quantity: 2, price_per_item: item_1.price)
      oi_6 = create(:order_item, item: item_4, order: order_2, quantity: 6, price_per_item: item_4.price)

      #order 3 with shipped status for current merchant's item.
      oi_7 = create(:order_item, item: item_3, order: order_3, quantity: 6, price_per_item: item_2.price)

      #order 4 with only other merchant's items.
      oi_8 = create(:order_item, item: item_1, order: order_4, quantity: 5, price_per_item: item_1.price)

      expect(item_3.item_fulfilled?(order_2)).to eq(true)
      expect(item_2.item_fulfilled?(order_2)).to eq(false)
      expect(item_2.item_fulfilled?(order_1)).to eq(false)

      expect(item_4.sufficient_inventory?(order_2)).to eq(false)
      expect(item_2.sufficient_inventory?(order_2)).to eq(true)
      expect(item_2.sufficient_inventory?(order_1)).to eq(true)
    end

    it "#item_orders returns order_item objects for a specific item in an order" do
      user = create(:user)
      order_1 = create(:order, user: user)

      user_2 = create(:user)
      order_2 = create(:order, user: user_2)

      merchant = create(:merchant)
      item_1 = create(:item, user: merchant)

      oi_1 = create(:order_item, item: item_1, order: order_1, quantity: 3, price_per_item: item_1.price)
      oi_2 = create(:order_item, item: item_1, order: order_2, quantity: 5, price_per_item: item_1.price)

      expect(item_1.item_orders(order_1)).to eq([oi_1])
      expect(item_1.item_orders(order_2)).to eq([oi_2])
    end

    it "#bulk_price returns the bulk price of an item when given a quantity" do
      merchant_1 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      bulk_discount_1 = create(:bulk_discount, user: merchant_1, bulk_quantity: 3, pc_off: 4)
      bulk_discount_2 = create(:bulk_discount, user: merchant_1, bulk_quantity: 5, pc_off: 20)
      bulk_discount_3 = create(:bulk_discount, user: merchant_1, bulk_quantity: 10, pc_off: 8)

      expect(item_1.bulk_price(1)).to eq(item_1.price)
      expect(item_1.bulk_price(2)).to eq(item_1.price)
      expect(item_1.bulk_price(3)).to eq(item_1.price * (100 - bulk_discount_1.pc_off)/100.0)
      expect(item_1.bulk_price(5)).to eq(item_1.price * (100 - bulk_discount_2.pc_off)/100.0)
      expect(item_1.bulk_price(6)).to eq(item_1.price * (100 - bulk_discount_2.pc_off)/100.0)
      expect(item_1.bulk_price(11)).to eq(item_1.price * (100 - bulk_discount_2.pc_off)/100.0) # not bulk_discount_3 because it's not as good of a deal
    end
  end
end
