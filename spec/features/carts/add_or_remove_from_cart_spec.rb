require 'rails_helper'

# to-do: consider combining / renaming to avoid confusion with carts/add_item_spec.rb

RSpec.describe "As a visitor", type: :feature do
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

  context 'I visit my cart with items' do
    it 'I see a button to add items to my cart' do
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
  end

  context 'I visit my cart with items ' do
    it 'I see a button to remove an item completely from cart' do
      visit cart_path

      within "#item-#{@item_2.id}" do
        click_button "Remove"
      end

      expect(page).to_not have_link("#{@item_2.name}")
      expect(page).to have_content("You have removed #{@item_2.name} from your cart")
    end
  end

  context 'I visit my cart with items ' do
    it 'I see a button to decrement item by 1 ' do

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
end
