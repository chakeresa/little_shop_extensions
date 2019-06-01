class Admin::AdminsController < Admin::BaseController
  def show
    @packaged_orders = Order.packaged_orders
    @pending_orders = Order.pending_orders
    @shipped_orders = Order.shipped_orders
    @cancelled_orders = Order.cancelled_orders
  end

  def ship_order
    order = Order.find(params[:id])
    order.update(status: 'shipped')
    flash[:success] = "#{order.id} has been shipped!"
    redirect_to admin_dashboard_path
  end
end
