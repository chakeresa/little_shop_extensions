require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    it {should validate_presence_of :nickname}
    it {should validate_presence_of :street}
    it {should validate_presence_of :city}
    it {should validate_presence_of :state}
    it {should validate_presence_of :zip}
  end

  describe 'relationships' do
    it {should belong_to :user}
    it {should have_many :orders}
  end

  describe "instance methods" do
    it "#no_completed_orders? returns true if the address has no associated shipped/packaged orders" do
      address_1 = create(:address)
      expect(address_1.no_completed_orders?).to eq(true)

      address_2 = create(:address)
      pending_order = create(:order, address: address_2)
      expect(address_2.no_completed_orders?).to eq(true)

      address_3 = create(:address)
      cancelled_order = create(:cancelled_order, address: address_3)
      expect(address_3.no_completed_orders?).to eq(true)

      address_4 = create(:address)
      packaged_order = create(:packaged_order, address: address_4)
      expect(address_4.no_completed_orders?).to eq(false)

      address_5 = create(:address)
      shipped_order = create(:shipped_order, address: address_5)
      expect(address_5.no_completed_orders?).to eq(false)
    end
  end
end
