class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @bulk_discounts = current_user.bulk_discounts.where.not(id: nil)
  end

  def new
  end

  def edit
  end

  def destroy
    bulk_discount = BulkDiscount.find(params[:id])
    if current_user.id == bulk_discount.user_id
      bulk_discount.destroy
      redirect_to merchant_bulk_discounts_path
    else
      render file: "/public/404", status: 404
    end
  end
end
