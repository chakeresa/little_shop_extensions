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
    it "#no_orders? returns true if the address has no associated orders" do
      address_1 = create(:address)
      address_2 = create(:address)
      order = create(:order, address: address_1)

      expect(address_1.no_orders?).to eq(false)
      expect(address_2.no_orders?).to eq(true)
    end
  end
end
