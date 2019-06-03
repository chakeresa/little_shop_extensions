require 'rails_helper'

RSpec.describe 'Bulk Discount Edit Form' do
  describe 'as a merchant' do
    before :each do
      @merchant = create(:merchant)
      address = create(:address, user: @merchant)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      @bulk_quantity = 6
      @pc_off = 30.0
    end

    it "has a form to add a new bulk discount" do
      visit new_merchant_bulk_discount_path

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(merchant_bulk_discounts_path)

      new_discount = BulkDiscount.last

      expect(page).to have_content("A new bulk discount was added")
      expect(new_discount.bulk_quantity).to eq(@bulk_quantity)
      expect(new_discount.pc_off).to eq(@pc_off)
    end

    it "requires bulk_quantity input" do
      visit new_merchant_bulk_discount_path

      # DON'T fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity is not a number")
      expect(BulkDiscount.count).to eq(0)
    end

    it "bulk_quantity input must be 2 or greater" do
      visit new_merchant_bulk_discount_path

      fill_in "bulk_discount[bulk_quantity]", with: "hello"
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity is not a number")
      expect(BulkDiscount.count).to eq(0)

      fill_in "bulk_discount[bulk_quantity]", with: "-5"
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity must be greater than or equal to 2")
      expect(BulkDiscount.count).to eq(0)

      fill_in "bulk_discount[bulk_quantity]", with: 1
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity must be greater than or equal to 2")
      expect(BulkDiscount.count).to eq(0)

      fill_in "bulk_discount[bulk_quantity]", with: 4.5
      fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Bulk quantity must be an integer")
      expect(BulkDiscount.count).to eq(0)
    end

    it "requires pc_off input" do
      visit new_merchant_bulk_discount_path

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      # DON'T fill_in "bulk_discount[pc_off]", with: @pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off is not a number")
      expect(BulkDiscount.count).to eq(0)
    end

    it "pc_off input must be 0.01 or greater" do
      visit new_merchant_bulk_discount_path

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: "hello"

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off is not a number")
      expect(BulkDiscount.count).to eq(0)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: "-3.2"

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off must be greater than or equal to 0.01")
      expect(BulkDiscount.count).to eq(0)

      fill_in "bulk_discount[bulk_quantity]", with: @bulk_quantity
      fill_in "bulk_discount[pc_off]", with: 0.0

      click_button "Create Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
      expect(page).to have_field("bulk_discount[bulk_quantity]")
      expect(page).to have_content("Pc off must be greater than or equal to 0.01")
      expect(BulkDiscount.count).to eq(0)
    end
  end
end
