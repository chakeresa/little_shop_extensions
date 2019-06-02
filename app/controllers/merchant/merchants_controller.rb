class Merchant::MerchantsController < Merchant::BaseController
  def show
    @merchant = current_user
    @address = @merchant.addresses.first
    @merchant_orders = Order.pending_merchant_orders(@merchant)
  end
end
