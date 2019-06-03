class Merchant::BulkDiscountsController < Merchant::BaseController
  def index
    @bulk_discounts = current_user.bulk_discounts.where.not(id: nil)
  end

  def new
    @bulk_discount = BulkDiscount.new
  end

  def create
    bulk_discount = BulkDiscount.new(bulk_discount_params)
    if bulk_discount.save
      flash[:success] = "A new bulk discount was added"
      redirect_to merchant_bulk_discounts_path
    else
      flash[:danger] = bulk_discount.errors.full_messages.join(". ")
      redirect_to new_merchant_bulk_discount_path
    end
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

  private

  def bulk_discount_params
    params[:bulk_discount][:user_id] = current_user.id
    params.require(:bulk_discount).permit(:bulk_quantity, :pc_off, :user_id)
  end
end
