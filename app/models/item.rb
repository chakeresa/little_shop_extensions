class Item < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :orders, through: :order_items

  validates_presence_of :name,
                        :price,
                        :description,
                        :inventory

  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :inventory, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  DEFAULT_IMAGE = "https://www.ultimate-realty.com/wp-content/uploads/sites/6518/2019/04/Image-Coming-Soon.png"

  def self.active_items
    self.where(active: true).order(:id)
  end

  def self.sort_by_popularity(limit, direction)
    self.joins(:order_items)
    .select("items.*, sum(order_items.quantity) AS total_quantity")
    .where("order_items.fulfilled = true")
    .group(:id)
    .order("total_quantity #{direction.to_s}")
    .limit(limit)
  end

  def average_fulfillment_time
    if order_items.where("order_items.fulfilled").count > 0
      order_items.where("order_items.fulfilled").average("updated_at - created_at").to_i
    end
  end

  def order_count
    orders.count
  end

  def purchase_price(order)
    order_items.where("order_items.order_id=?", order.id)
              .first
              .price_per_item
  end

  def purchase_quantity(order)
    order_items.where("order_items.order_id=?", order.id)
              .first
              .quantity
  end

  def item_fulfilled?(order)
    order_items.where("order_items.order_id=?", order.id).first.fulfilled
  end

  def item_orders(order)
    order_items.where("order_items.order_id=?", order.id)
  end

  def sufficient_inventory?(order)
    item_quantity = order_items.where("order_items.order_id=?", order.id).first.quantity
    inventory >= item_quantity
  end

  def bulk_price(quantity)
    percent_off = 0
    if discount = highest_applicable_discount(quantity)
      percent_off = discount.pc_off
    end
    price * (100 - percent_off) / 100.0
  end

  def highest_applicable_discount(quantity)
    user.highest_applicable_discount(quantity)
  end
end
