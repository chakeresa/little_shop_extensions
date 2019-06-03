require 'rails_helper'

RSpec.describe 'Merchant Bulk Discounts Index' do
  describe 'as a merchant' do
    before :each do
      @merchant = create(:merchant)
      address = create(:address, user: @merchant)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    end

    it "has a link to add a new bulk discount" do
      visit merchant_bulk_discounts_path

      click_link "Add a New Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path)
    end

    it "has a list of all my bulk discounts and their info" do
      discount_1 = create(:bulk_discount, user: @merchant)
      discount_2 = create(:bulk_discount, user: @merchant)
      discount_3 = create(:bulk_discount)

      visit merchant_bulk_discounts_path

      within("#bulk-discount-#{discount_1.id}") do
        expect(page).to have_content(discount_1.bulk_quantity)
        expect(page).to have_content(number_to_percentage(discount_1.pc_off, precision: 2))
      end

      within("#bulk-discount-#{discount_2.id}") do
        expect(page).to have_content(discount_2.bulk_quantity)
        expect(page).to have_content(number_to_percentage(discount_2.pc_off, precision: 2))
      end

      expect(page).to_not have_content(discount_3.bulk_quantity)
    end
  end
end
