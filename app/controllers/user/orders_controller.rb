class User::OrdersController < User::BaseController
  def index
    @user_orders = current_user.orders
  end

  def show
    @order = Order.find(params[:id])
    @address = @order.address
    @addresses = current_user.addresses
    @items = @order.items
  end

  def update
    @order = Order.find(params[:id])
    if @order.user_id == current_user.id
      change_address
      redirect_to user_order_path(@order)
    else
      render file: "/public/404", status: 404
    end
  end

  def cancel
    order = Order.find(params[:id])
    order.cancel

    flash[:success] = "Order #{order.id} has been cancelled"
    redirect_to profile_path
  end

  private

  def change_address
    if @order.status == "pending"
      @order.update(address_id: params[:order][:address_id])
      flash[:success] = "Shipping address succcessfully changed"
    else
      flash[:danger] = "Shipping address can only be changed for pending orders"
    end
  end
end
