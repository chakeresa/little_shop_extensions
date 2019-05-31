class Admin::MerchantsController < Admin::BaseController
  def show
    @merchant = User.find(params[:id])
    @pending_orders = Order.pending_merchant_orders(@merchant)
    if @merchant.user?
      redirect_to admin_user_path(@merchant)
    end
  end

  def index
    @merchants = User.all_merchants
  end

  def disable
    merchant = User.find(params[:id])
    merchant.update(active: false)
    flash[:success] = "#{merchant.name}'s account is now disabled."
    redirect_to admin_merchants_path
  end

  def enable
    merchant = User.find(params[:id])
    merchant.update(active: true)
    flash[:success] = "#{merchant.name}'s account is now enabled.'"
    redirect_to admin_merchants_path
  end

  def downgrade
    merchant = User.find(params[:id])
    merchant.downgrade_to_regular_user
    flash[:success] = "#{merchant.name} has been downgraded to a regular user"
    redirect_to admin_user_path(merchant)
  end
end
