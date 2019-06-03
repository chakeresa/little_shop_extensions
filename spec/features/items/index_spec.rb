require 'rails_helper'

RSpec.describe "items index page, " do
  context "as a visitor" do
    before :each do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @item_1 = @merchant_1.items.create!(name: 'Item 1', active: true, price: 1.00, description: 'Stuff 1', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 1)
      @item_2 = @merchant_1.items.create!(name: 'Item 2', active: true, price: 2.00, description: 'Stuff 2', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 2)
      @item_3 = @merchant_2.items.create!(name: 'Item 3', active: true, price: 3.00, description: 'Stuff 3', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 3)

      @item_4 = @merchant_2.items.create!(name: 'Item 4', active: false, price: 4.00, description: 'Stuff 4', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 4)
      @item_5 = @merchant_1.items.create!(name: 'Item 5', active: false, price: 5.00, description: 'Stuff 5', image: 'https://luciteacrylic.com/wp-content/uploads/2018/01/Product-Image-Coming-Soon.png', inventory: 5)
    end

    it "I see all active items only" do
      visit items_path

      within "#item-id-#{@item_1.id}" do
        expect(page).to have_link(@item_1.name)
        expect(page).to have_content(number_to_currency(@item_1.price))
        expect(page).to have_content("Description: #{@item_1.description}")
        expect(page).to have_css("img[src*='#{@item_1.image}']")
        expect(page).to have_content("#{@item_1.inventory} in stock")
      end

      within "#item-id-#{@item_2.id}" do
        expect(page).to have_link(@item_2.name)
        expect(page).to have_content(number_to_currency(@item_2.price))
        expect(page).to have_content("Description: #{@item_2.description}")
        expect(page).to have_css("img[src*='#{@item_2.image}']")
        expect(page).to have_content("#{@item_2.inventory} in stock")
      end

      expect(page).to_not have_content(@item_4.name)
    end
  end
end

context "statistics area" do
  before(:each) do
    @merchant = create(:merchant)

    @user_1 = create(:user)
    @user_2 = create(:user)
    @user_3 = create(:user)

    @item_1 = create(:item, user: @merchant, inventory: 20)
    @item_2 = create(:item, user: @merchant, inventory: 20)
    @item_3 = create(:item, user: @merchant, inventory: 20)
    @item_4 = create(:item, user: @merchant, inventory: 20)
    @item_5 = create(:item, user: @merchant, inventory: 20)
    @item_6 = create(:item, user: @merchant, inventory: 20)

    @order_1 = create(:shipped_order, user: @user_1)
    @order_2 = create(:shipped_order, user: @user_2)
    @order_3 = create(:shipped_order, user: @user_3)
    @order_4 = create(:shipped_order, user: @user_1)
    @order_5 = create(:shipped_order, user: @user_1)
    @order_6 = create(:shipped_order, user: @user_2)
    @order_7 = create(:cancelled_order, user: @user_2)
    @order_8 = create(:order, user: @user_2)

    @order_items_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100)
    @order_items_2 = create(:fulfilled_order_item, item: @item_2 , order: @order_2, quantity: 99)
    @order_items_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3 , quantity: 98)
    @order_items_4 = create(:fulfilled_order_item, item: @item_4 , order: @order_4, quantity: 97)
    @order_items_5 = create(:fulfilled_order_item, item: @item_5, order: @order_5, quantity: 96)
    @order_items_6 = create(:order_item, item: @item_3, order: @order_6, quantity: 95)
    @order_items_7 = create(:order_item, item: @item_6, order: @order_7, quantity: 101)
    @order_items_8 = create(:order_item, item: @item_6, order: @order_8, quantity: 102)
  end

  describe "displays the most (top 5) and least (bottom 5) popular items" do
    it "popularity is determined by total quantity of that item fulfilled" do

      visit items_path

      within "#statistics-most-popular" do
        expect(page.all('li')[0]).to have_content("#{@item_1.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :desc)[0].total_quantity}")
        expect(page.all('li')[1]).to have_content("#{@item_2.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :desc)[1].total_quantity}")
        expect(page.all('li')[2]).to have_content("#{@item_3.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :desc)[2].total_quantity}")
        expect(page.all('li')[3]).to have_content("#{@item_4.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :desc)[3].total_quantity}")
        expect(page.all('li')[4]).to have_content("#{@item_5.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :desc)[4].total_quantity}")
      end

      within "#statistics-least-popular" do
        expect(page.all('li')[0]).to have_content("#{@item_5.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :asc)[0].total_quantity}")
        expect(page.all('li')[1]).to have_content("#{@item_4.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :asc)[1].total_quantity}")
        expect(page.all('li')[2]).to have_content("#{@item_3.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :asc)[2].total_quantity}")
        expect(page.all('li')[3]).to have_content("#{@item_2.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :asc)[3].total_quantity}")
        expect(page.all('li')[4]).to have_content("#{@item_1.name}, Total quantity fulfilled: #{Item.sort_by_popularity(5, :asc)[4].total_quantity}")
      end
    end
  end
end
