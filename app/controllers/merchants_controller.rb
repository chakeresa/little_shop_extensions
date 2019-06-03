class MerchantsController < ApplicationController
  def index
    @active_merchants = User.active_merchants
    @inactive_merchants = User.inactive_merchants
    @top_3_orders_by_quantity = Order.top_3_by_quantity
    @top_3_merchants_by_revenue = User.top_3_by_revenue
    @top_3_merchants_by_quantity = User.top_3_merch_by_quantity
    @fastest_3_merchants = User.fastest_3_merchants
    @slowest_3_merchants = User.slowest_3_merchants
    @top_3_states = Order.top_3_states
    @top_3_cities = Order.top_3_cities
  end
end
