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
  end
end
