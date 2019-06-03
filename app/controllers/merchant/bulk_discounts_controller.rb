class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @bulk_discounts = current_user.bulk_discounts.where.not(id: nil)
  end
end
