class User::OrdersController < User::BaseController
  def index
    @user_orders = current_user.orders
  end

  def show
    @order = Order.find(params[:id])
    @items = @order.items
  end

  def cancel
    order = Order.find(params[:id])
    order.update(status: "cancelled")

    order.order_items.each do |order_item|
      order_item.cancel
    end

    flash[:success] = "Order #{order.id} has been cancelled"
    redirect_to profile_path
  end
end
