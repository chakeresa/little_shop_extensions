class CartsController < ApplicationController
  include ActionView::Helpers::TextHelper

  def add_from_show_page
    item = Item.find(params[:id])
    add_to_cart(item)
    session[:cart] = cart.contents
    redirect_to items_path
  end


  def increment
    item = Item.find(params[:id])
    add_to_cart(item)
    session[:cart] = cart.contents
    flash[:success] = "You have added 1 #{item.name} to your cart."
    redirect_back fallback_location: cart_path
  end

  def decrement
    item = Item.find(params[:id])
    cart.remove_item(item.id)
    flash[:success] = "You have removed 1 #{item.name} from your cart."
    session[:cart] = cart.contents
    redirect_back fallback_location: cart_path
  end

  def remove_item
    item = Item.find(params[:id])
    cart.remove_all_item(item.id)
    flash[:success] = "You now removed all #{item.name} in your cart."
    session[:cart] = cart.contents
    redirect_back fallback_location: cart_path
  end

  def show
    if current_user && (current_user.admin? || current_user.merchant?)
      render file: "/public/404", status: 404
    end
  end

  def destroy
    session.delete(:cart)
    flash[:success] = "Your cart is now empty"
    redirect_to cart_path
  end

  def checkout
    new_order = current_user.orders.create
    cart.item_and_quantity_hash.each do |item, quantity|
      OrderItem.create(item: item, order: new_order, quantity: quantity, price_per_item: item.price)
    end
    session.delete(:cart)
    flash[:success] = "Your order was created!"
    redirect_to user_orders_path
  end

  private

  def add_to_cart(item)
    if cart.count_of(item.id) + 1 <= item.inventory
      cart.add_item(item.id)
      quantity = cart.count_of(item.id)
      flash[:success] = "You now have #{pluralize(quantity, item.name)} in your cart."
    else
      flash[:danger] = "Merchant does not have any more #{item.name}"
    end
  end
end
