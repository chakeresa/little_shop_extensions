require 'rails_helper'

RSpec.describe "Cart checkout functionality: " do
  describe "as a logged in regular user" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, name: "Sofa")
      @item_2 = create(:item, user: @merchant_1, name: "Chair")

      @user_1 = create(:user)
      @addr_1 = create(:address, user: @user_1)
      @addr_2 = create(:address, user: @user_1)
      @user_1.update!(primary_address_id: @addr_2.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit item_path(@item_1)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit item_path(@item_1)
      click_button "Add to Cart"
    end

    it "I see a button to check out" do
      visit cart_path

      expect(page).to have_button("Check Out")
    end

    it "I can check out and see my order" do
      visit cart_path

      find('#order_address_id').select(@addr_1.street)
      click_button 'Check Out'

      expect(page).to have_content("Your order was created!")

      expect(current_path).to eq(user_orders_path)
      expect(page).to have_link("Order #{Order.last.id}")
      expect(page).to have_content("pending")
      expect(page).to have_content("Cart: 0")
      expect(page).to have_content("Shipping to #{@addr_1.nickname} address: #{@addr_1.street}, #{@addr_1.city}, #{@addr_1.state}, #{@addr_1.zip}")
    end

    it "applies bulk discounts when creating an order" do
      bulk_discount = create(:bulk_discount, user: @merchant_1, bulk_quantity: 2) # will apply for item_1

      visit cart_path

      find('#order_address_id').select(@addr_1.street)
      click_button 'Check Out'

      new_order = Order.last

      oi_1 = new_order.order_items.first
      oi_2 = new_order.order_items.last

      expect(oi_1.item_id).to eq(@item_1.id)
      expect(oi_2.item_id).to eq(@item_2.id)

      expect(oi_1.price_per_item).to eq(@item_1.price * (100 - bulk_discount.pc_off)/100.0)
      expect(oi_2.price_per_item).to eq(@item_2.price)
    end

    it "defaults to my primary address" do
      visit cart_path

      click_button 'Check Out'

      expect(page).to have_content("Your order was created!")

      expect(current_path).to eq(user_orders_path)
      expect(page).to have_link("Order #{Order.last.id}")
      expect(page).to have_content("pending")
      expect(page).to have_content("Cart: 0")
      expect(page).to have_content("Shipping to #{@addr_2.nickname} address: #{@addr_2.street}, #{@addr_2.city}, #{@addr_2.state}, #{@addr_2.zip}")
    end
  end

  describe "as a logged in regular user with no addresses" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, name: "Sofa")
      @item_2 = create(:item, user: @merchant_1, name: "Chair")

      @user_1 = create(:user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit item_path(@item_1)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit item_path(@item_1)
      click_button "Add to Cart"
    end

    it "I see a message to add an address" do
      visit cart_path

      expect(page).to have_content("Add an address to check out")
      expect(page).to have_link('Add a New Address')
      expect(page).to_not have_button('Check Out')
    end
  end

  context "as a visitor with items in my cart" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, name: "Sofa")
      @item_2 = create(:item, user: @merchant_1, name: "Chair")

      visit item_path(@item_1)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit item_path(@item_1)
      click_button "Add to Cart"
    end

    it "doesn't show a checkout button" do
      visit cart_path

      expect(page).to_not have_button("Check Out")
    end

    it "displays information telling me I must register or log in (as a regular user) to finish the checkout process" do
      visit cart_path

      expect(page).to have_content("Cart: 3")
      expect(page).to have_content("You must register or log in to finish the checkout process.")

      within "#visitor-checkout" do
        expect(page).to have_link("register")
        click_on "register"
        expect(current_path).to eq(register_path)
      end

      visit cart_path

      within "#visitor-checkout" do
        expect(page).to have_link("log in")
        click_on "log in"
        expect(current_path).to eq(login_path)
      end
    end

    it "does not display log in or register information for a logged-in user" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit cart_path

      expect(page).to have_content("Cart: 3")

      expect(page).to_not have_content("You must register or log in to finish the checkout process.")
      expect(page).to_not have_link("register")
      expect(page).to_not have_link("log in")
    end
  end


  describe "as a merchant" do
    it "doesn't show a checkout button" do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit cart_path

      expect(page).to_not have_button("Check Out")
    end
  end

  describe "as an admin" do
    it "doesn't show a checkout button" do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit cart_path

      expect(page).to_not have_button("Check Out")
    end
  end
end
