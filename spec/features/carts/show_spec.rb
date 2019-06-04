require 'rails_helper'

RSpec.describe "cart show page", type: :feature do
  context "as a visitor" do
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

    it 'shows all items in the cart' do
      visit cart_path

      expect(page).to have_button("Empty Cart")

      within("#item-#{@item_1.id}") do
        expect(page).to have_link(@item_1.name)
        expect(page).to have_css("img[src*='#{@item_1.image}']")
        expect(page).to have_content(@item_1.user.name)
        expect(page).to have_content(number_to_currency(@item_1.price))
        expect(page).to have_content("2")
        expect(page).to have_content("Subtotal: #{number_to_currency(2 * @item_1.price)}")
      end

      within("#item-#{@item_2.id}") do
        expect(page).to have_link(@item_2.name)
        expect(page).to have_css("img[src*='#{@item_2.image}']")
        expect(page).to have_content(@item_2.user.name)
        expect(page).to have_content(number_to_currency(@item_2.price))
        expect(page).to have_content("1")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item_2.price)}")
      end

      expect(page).to have_content("Grand Total: #{number_to_currency(2 * @item_1.price +  @item_2.price)}")
    end

    it "I click on Empty Cart, all items are removed" do
      visit cart_path
      click_button "Empty Cart"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("Your cart is now empty")

      expect(page).to have_content("Cart: 0")
      expect(page).to_not have_link(@item_1.name)
      expect(page).to_not have_link(@item_2.name)
    end
  end

  context "as a visitor with an empty cart" do
    it "should only display, your cart is empty" do
      visit root_path

      click_on "My Cart"

      expect(page).to have_content("There is nothing in your cart!")
      expect(page).to_not have_link("Empty Cart")
      expect(page).to_not have_content("Grand Total")
    end
  end

  context "as a user" do
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

    it 'shows all items in the cart' do
      visit cart_path

      expect(page).to have_button("Empty Cart")

      within("#item-#{@item_1.id}") do
        expect(page).to have_link(@item_1.name)
        expect(page).to have_css("img[src*='#{@item_1.image}']")
        expect(page).to have_content(@item_1.user.name)
        expect(page).to have_content(number_to_currency(@item_1.price))
        expect(page).to have_content("2")
        expect(page).to have_content("Subtotal: #{number_to_currency(2 * @item_1.price)}")
      end

      within("#item-#{@item_2.id}") do
        expect(page).to have_link(@item_2.name)
        expect(page).to have_css("img[src*='#{@item_2.image}']")
        expect(page).to have_content(@item_2.user.name)
        expect(page).to have_content(number_to_currency(@item_2.price))
        expect(page).to have_content("1")
        expect(page).to have_content("Subtotal: #{number_to_currency(@item_2.price)}")
      end

      expect(page).to have_content("Grand Total: #{number_to_currency(2 * @item_1.price +  @item_2.price)}")
    end

    it 'applies the best bulk discount' do
      bd_1 = create(:bulk_discount, user: @merchant_1, bulk_quantity: 3)
      # 2 of merchant_1's item_1 total - bulk discount does NOT apply (not enough)

      # 3 of merchant_1's item_2 total - bulk discount DOES apply
      visit item_path(@item_2)
      click_button "Add to Cart"
      visit item_path(@item_2)
      click_button "Add to Cart"

      # 3 of merchant_1's item_2 total - bulk discount does NOT apply (wrong merchant)
      merchant_2 = create(:merchant)
      item_3 = create(:item, user: merchant_2, name: "Sofa")
      visit item_path(item_3)
      click_button "Add to Cart"
      visit item_path(item_3)
      click_button "Add to Cart"
      visit item_path(item_3)
      click_button "Add to Cart"

      visit cart_path

      within("#item-#{@item_1.id}") do
        item_1_subtotal = 2 * @item_1.price
        expect(page).to have_content(number_to_currency(@item_1.price))
        expect(page).to have_content("Subtotal: #{number_to_currency(item_1_subtotal)}")
      end

      within("#item-#{@item_2.id}") do
        item_2_subtotal = 3 * @item_2.price * (100-bd_1.pc_off)/100.0
        expect(page).to have_content(number_to_currency(@item_2.price))
        expect(page).to have_content("Subtotal: #{number_to_currency(item_2_subtotal)}")
      end

      within("#item-#{@item_3.id}") do
        item_3_subtotal = 3 * item_3.price
        expect(page).to have_content(number_to_currency(@item_2.price))
        expect(page).to have_content("Subtotal: #{number_to_currency(item_3_subtotal)}")
      end

      expect(page).to have_content("Grand Total: #{number_to_currency(item_1_subtotal + item_2_subtotal + item_3_subtotal)}")
    end

    it "I click on Empty Cart, all items are removed" do
      visit cart_path
      click_button "Empty Cart"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("Your cart is now empty")

      expect(page).to have_content("Cart: 0")
      expect(page).to_not have_link(@item_1.name)
      expect(page).to_not have_link(@item_2.name)
    end
  end


  context "as a user with an empty cart" do
    it "should only display, your cart is empty" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit root_path

      click_on "My Cart"

      expect(page).to have_content("There is nothing in your cart!")
      expect(page).to_not have_link("Empty Cart")
      expect(page).to_not have_content("Grand Total")
    end
  end
end
