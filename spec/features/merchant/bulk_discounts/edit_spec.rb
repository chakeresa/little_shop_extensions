require 'rails_helper'

RSpec.describe 'Bulk Discount Edit Form' do
  describe 'as a merchant' do
    before :each do
      @merchant = create(:merchant)
      address = create(:address, user: @merchant)
      @bulk_discount = create(:bulk_discount, user: @merchant)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      @bulk_quantity = 6
      @pc_off = 30.0
    end

    it "has a form to edit an existing bulk discount" do
      visit edit_merchant_bulk_discount_path(@bulk_discount)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Update Bulk Discount"

      expect(current_path).to eq(merchant_bulk_discounts_path)

      expect(page).to have_content("The bulk discount was updated")
      expect(@bulk_discount.reload.bulk_quantity).to eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to eq(@pc_off)
    end

    it "requires bulk_quantity input" do
      visit edit_merchant_bulk_discount_path(@bulk_discount)

      # DON'T fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity is not a number")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)
    end

    it "bulk_quantity input must be 2 or greater" do
      visit edit_merchant_bulk_discount_path(@bulk_discount)

      fill_in "bulk_discount[bulk_quantity]", with: "hello"
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity is not a number")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)

      fill_in "bulk_discount[bulk_quantity]", with: "-5"
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity must be greater than or equal to 2")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)

      fill_in "bulk_discount[bulk_quantity]", with: 1
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity must be greater than or equal to 2")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)

      fill_in "bulk_discount[bulk_quantity]", with: 4.5
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity must be an integer")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)
    end

    it "requires pc_off input" do
      visit edit_merchant_bulk_discount_path(@bulk_discount)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      # DON'T fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off is not a number")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)
    end

    it "pc_off input must be 0.01 or greater" do
      visit edit_merchant_bulk_discount_path(@bulk_discount)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: "hello"

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off is not a number")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: "-3.2"

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off must be greater than or equal to 0.01")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: 0.0

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off must be greater than or equal to 0.01")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)
    end

    it "pc_off input must be 99.99 or less" do
      visit edit_merchant_bulk_discount_path(@bulk_discount)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: 100

      click_button "Create Bulk Discount"

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@bulk_discount))
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off must be less than or equal to 99.99")
      expect(@bulk_discount.reload.bulk_quantity).to_not eq(@bulk_quantity)
      expect(@bulk_discount.reload.pc_off).to_not eq(@pc_off)
    end
  end
end
