require 'rails_helper'

RSpec.describe 'Bulk Discount Edit Form' do
  describe 'as a merchant' do
    before :each do
      @merchant = create(:merchant)
      address = create(:address, user: @merchant)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    end

    it "has a form to add a new bulk discount" do
      visit new_merchant_bulk_discount_path

      bulk_quantity = 6
      pc_off = 30.0

      fill_in "bulk_discount[bulk_quantity]", with: bulk_quantity
      fill_in "bulk_discount[pc_off]", with: pc_off

      click_button "Create Bulk Discount"

      expect(current_path).to eq(merchant_bulk_discounts_path)

      new_discount = BulkDiscount.last

      expect(page).to have_content("A new bulk discount was added")
      expect(new_discount.bulk_quantity).to eq(bulk_quantity)
      expect(new_discount.pc_off).to eq(pc_off)
    end
  end
end
