class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :items, through: :order_items

  validates_presence_of :status

  enum status: ['pending', 'packaged', 'shipped', 'cancelled']

  def self.packaged_orders
    where(status: "packaged").order(:id)
  end

  def self.pending_orders
    where(status: "pending").order(:id)
  end

  def self.shipped_orders
    where(status: "shipped").order(:id)
  end

  def self.cancelled_orders
    where(status: "cancelled").order(:id)
  end

  def self.pending_merchant_orders(merchant)
    Order.joins(items: :order_items)
        .where(status: 0)
        .where("items.user_id = ?", merchant.id)
        .distinct
        .order(:id)
  end

  def self.top_3_by_quantity
    self.joins(:order_items)
        .select("sum(order_items.quantity) as total_quantity, orders.*")
        .where(status: "shipped")
        .group(:id)
        .order("total_quantity DESC")
        .limit(3)
  end

  def grand_total
    order_items.sum do |order_item|
      order_item.price_per_item * order_item.quantity
    end
  end

  def total_quantity
    order_items.sum(:quantity)
  end

  def item_price(item)
    if items.include?(item)
      order_items.where(item: item).first.price_per_item
    end
  end

  def item_quantity(item)
    if items.include?(item)
      order_items.where(item: item).first.quantity
    else
      0
    end
  end

  def item_subtotal(item)
    if items.include?(item)
      order_item = order_items.where(item: item).first
      order_item.quantity * order_item.price_per_item
    else
      0
    end
  end

  def merchant_items(merchant)
    items.where("items.user_id = ?", merchant.id).order("items.name")
  end

  def total_quantity_for_merchant(merchant)
    items.joins(:order_items)
        .select("items.*, order_items.quantity")
        .where("items.user_id=?",merchant.id)
        .distinct
        .sum('order_items.quantity')
  end

  def total_value_for_merchant(merchant)
    items.joins(:order_items)
        .select("items.*, order_items.*")
        .where("items.user_id=?",merchant.id)
        .distinct
        .sum("order_items.quantity * order_items.price_per_item")
  end

  def cancel
    update(status: "cancelled")

    order_items.each do |order_item|
      order_item.cancel
    end
  end
end
