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

    it "has links to edit my bulk discounts" do
      discount_1 = create(:bulk_discount, user: @merchant)
      discount_2 = create(:bulk_discount, user: @merchant)

      visit merchant_bulk_discounts_path

      within("#bulk-discount-#{discount_1.id}") do
        expect(page).to have_link("Edit Discount")
      end

      within("#bulk-discount-#{discount_2.id}") do
        click_link "Edit Discount"
      end

      expect(current_path).to eq(edit_merchant_bulk_discount_path(discount_2))
    end

    it "has buttons to delete my bulk discounts" do
      discount_1 = create(:bulk_discount, user: @merchant)
      discount_2 = create(:bulk_discount, user: @merchant)

      visit merchant_bulk_discounts_path

      within("#bulk-discount-#{discount_1.id}") do
        expect(page).to have_button("Delete Discount")
      end

      within("#bulk-discount-#{discount_2.id}") do
        click_button "Delete Discount"
      end

      expect(current_path).to eq(merchant_bulk_discounts_path)
      expect(page).to_not have_content(discount_2.bulk_quantity)
      expect(@merchant.bulk_discounts).to eq([discount_1])
    end

    it "I cannot delete another merchant's bulk discounts" do
      discount_1 = create(:bulk_discount, user: @merchant)

      visit merchant_bulk_discounts_path

      discount_1.update(user: create(:merchant))

      within("#bulk-discount-#{discount_1.id}") do
        click_button "Delete Discount"
      end

      expect(status_code).to eq(404)
      expect(BulkDiscount.count).to eq(1)
    end
  end
end
