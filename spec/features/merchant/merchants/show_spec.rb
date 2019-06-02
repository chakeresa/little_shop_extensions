require 'rails_helper'

RSpec.describe 'As a merchant user: ' do
  describe 'I visit my dashboard, ' do
    before :each do
      @merchant = create(:merchant)
      address = create(:address, user: @merchant)
      @merchant.update!(primary_address_id: address.id)

      @other_merchant = create(:merchant)
    end

    it "displays my profile data" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit merchant_dashboard_path

      within "#dashboard-show" do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content(@merchant.email)
        expect(page).to have_content(@merchant.primary_address.street)
        expect(page).to have_content("#{@merchant.primary_address.city}, #{@merchant.primary_address.state}")
        expect(page).to have_content(@merchant.primary_address.zip)

        expect(page).to_not have_content(@other_merchant.name)
      end
    end
  end
end
