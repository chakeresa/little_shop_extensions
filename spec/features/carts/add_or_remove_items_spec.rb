require 'rails_helper'

RSpec.describe "adding or removing items from their cart" do
  context "as a visitor with an empty cart" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, name: "Sofa")
      @item_2 = create(:item, user: @merchant_1, name: "Chair")
    end

    it "displays a message when I add an item to my cart" do
      visit item_path(@item_1)
      click_button "Add to Cart"

      expect(page).to have_content("You now have 1 #{@item_1.name} in your cart")
      expect(current_path).to eq(items_path)
    end

    it "the message correctly increments for multiple items" do
      visit item_path(@item_1)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit item_path(@item_1)
      click_button "Add to Cart"

      expect(page).to have_content("You now have 2 #{@item_1.name}s in your cart")
    end

    it "displays the total number of items in the cart" do
      visit item_path(@item_1)

      expect(page).to have_content("Cart: 0")

      click_button "Add to Cart"

      expect(page).to have_content("Cart: 1")

      visit item_path(@item_2)
      click_button "Add to Cart"

      expect(page).to have_content("Cart: 2")

      visit item_path(@item_1)
      click_button "Add to Cart"

      expect(page).to have_content("Cart: 3")
    end
  end

  context "as a visitor with items in my cart" do
    before :each do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, name: "Sofa", inventory: 3)
      @item_2 = create(:item, user: @merchant_1, name: "Chair", inventory: 2)

      visit item_path(@item_1)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit item_path(@item_1)
      click_button "Add to Cart"
    end

    it 'I see buttons to increment/decrement the quantities in my cart' do
      visit cart_path

      expect(page).to have_button("+")
      expect(page).to have_button("-")
      expect(page).to have_button("Remove")

      within "#item-#{@item_1.id}" do
        click_button "+"
      end

      expect(page).to have_content("You now have #{pluralize(3, @item_1.name)} in your cart")

      within "#item-#{@item_1.id}" do
        click_button "+"
        expect(page).to have_content(@item_1.inventory)
      end

      expect(page).to have_content("Merchant does not have any more #{@item_1.name}")
    end

    it 'I see a button to remove an item completely from my cart' do
      visit cart_path

      within "#item-#{@item_2.id}" do
        click_button "Remove"
      end

      expect(page).to_not have_link("#{@item_2.name}")
      expect(page).to have_content("You have removed #{@item_2.name} from your cart")
    end

    it 'there is a button to decrement an item by 1' do
      visit item_path(@item_1)
      click_button "Add to Cart"

      visit cart_path

      within "#item-#{@item_1.id}" do
        click_button "-"
        expect(page).to have_content(@item_1.inventory - 1)
      end

      expect(page).to have_content("You have removed 1 #{@item_1.name} from your cart.")

      within "#item-#{@item_1.id}" do
        click_button "-"
        click_button "-"
      end

      expect(page).to_not have_link("#{@item_1.name}")
    end
  end

  context "as a user" do
    before(:each) do
      @merchant_1 = create(:merchant)
      @item_1 = create(:item, user: @merchant_1, name: "Sofa")
      @item_2 = create(:item, user: @merchant_1, name: "Chair")
      @user_1 = create(:user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)
    end

    it "displays a message when I add an item to my cart" do
      visit item_path(@item_1)
      click_button "Add to Cart"

      expect(page).to have_content("You now have 1 #{@item_1.name} in your cart")
    end

    it "the message correctly increments for multiple items" do
      visit item_path(@item_1)
      click_button "Add to Cart"

      visit item_path(@item_2)
      click_button "Add to Cart"

      visit item_path(@item_1)
      click_button "Add to Cart"

      expect(page).to have_content("You now have 2 #{@item_1.name}s in your cart")
    end

    it "displays the total number of items in the cart" do
      visit item_path(@item_1)

      expect(page).to have_content("Cart: 0")

      click_button "Add to Cart"

      expect(page).to have_content("Cart: 1")

      visit item_path(@item_2)
      click_button "Add to Cart"

      expect(page).to have_content("Cart: 2")

      visit item_path(@item_1)
      click_button "Add to Cart"

      expect(page).to have_content("Cart: 3")
    end
  end
end
