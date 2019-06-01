class User < ApplicationRecord
  before_save { self.email = email.downcase }

  validates :email, uniqueness: true, presence: true
  validates_presence_of :name,
                        :password_digest,
                        :role
  has_many :orders
  has_many :items
  has_one :primary_address, class_name: 'Address'
  has_many :addresses

  enum role: ['user', 'merchant', 'admin']


  has_secure_password

  def self.active_merchants
    where(active: true, role: 'merchant').order(:id)
  end

  def self.inactive_merchants
    where(active: false, role: 'merchant').order(:id)
  end

  def self.all_merchants
    where(role: 'merchant').order(:id)
  end

  def self.regular_users
    where(role: 'user').order(:id)
  end

  def self.top_3_by_revenue
    self.joins(items: :order_items)
        .joins("JOIN orders ON order_items.order_id = orders.id")
        .group(:id)
        .select("users.*, SUM(order_items.quantity * order_items.price_per_item) AS total_revenue")
        .where(active: true)
        .where("orders.status = 2")
        .order("total_revenue DESC")
        .limit(3)
  end

  def self.top_3_merch_by_quantity
    self.joins(items: :order_items)
        .joins("JOIN orders ON order_items.order_id = orders.id")
        .group(:id)
        .select("users.*, SUM(order_items.quantity) AS total_quantity")
        .where(active: true)
        .where("orders.status = 2")
        .order("total_quantity DESC")
        .limit(3)
  end

  def self.top_3_states
    self.joins(:orders)
        .select("users.state, count(orders) as order_count")
        .group("users.state")
        .where("orders.status = 2")
        .order("order_count DESC")
        .limit(3)
  end

  def self.top_3_cities
   self.joins(:orders)
       .select("users.state, users.city, count(orders) as order_count")
       .group("users.state, users.city")
       .where("orders.status = 2")
       .order("order_count DESC")
       .limit(3)
  end

  def self.average_fulfillment_times
    self.joins(items: :order_items)
        .select("AVG(order_items.updated_at - order_items.created_at) AS avg_time, users.*")
        .group(:id)
        .where("order_items.fulfilled = true")
  end

  def self.fastest_3_merchants
    self.average_fulfillment_times.order("avg_time").limit(3)
  end

  def self.slowest_3_merchants
    self.average_fulfillment_times.order("avg_time DESC").limit(3)
  end

  def total_revenue
    items.joins(:order_items)
         .joins("JOIN orders ON order_items.order_id = orders.id")
         .where("orders.status = 2")
         .sum("order_items.quantity * order_items.price_per_item")
  end

  def top_five_items
    items.select("items.*, sum(order_items.quantity) as total_sold")
         .joins(:orders)
         .group(:id)
         .where("orders.status = 2" )
         .order("total_sold desc")
         .limit(5)
  end

  def total_sold
    items.joins(:orders)
          .where(active: true)
          .where("orders.status = 2")
          .sum("order_items.quantity")
  end

  def total_inventory
    items.where(active: true).sum(:inventory)
  end

  def inventory_ratio
    (total_sold / total_inventory.to_f) * 100
  end

  def top_three_states
    User
      .select(:state, 'SUM(order_items.quantity) AS total_quantity')
      .joins(orders: :items)
      .where('orders.status = ?', 2)
      .where('items.user_id = ?', self.id)
      .group(:state)
      .order('total_quantity DESC')
      .limit(3)
  end

  def top_three_cities
    items.select("users.city, users.state, sum(order_items.quantity) as total_quantity")
         .joins(:orders)
         .joins("join users On orders.user_id = users.id")
         .group("users.city", "users.state")
         .where("orders.status = 2")
         .order("total_quantity desc")
         .limit(3)
  end

  def top_user_orders
    User
      .select("users.*, count(distinct(orders.id)) as total_orders")
      .joins(orders: :items)
      .where("items.user_id = ?", self.id)
      .where("users.active = ?", true)
      .where('order_items.fulfilled = ?', true)
      .where("orders.status = ?", 2)
      .group(:id)
      .order("total_orders DESC")
      .first
  end

  def top_user_items
    User
      .select("users.*, sum(order_items.quantity) as total_items")
      .joins(orders: :items)
      .where("items.user_id = ?", self.id)
      .where("users.active = ?", true)
      .where('order_items.fulfilled = ?', true)
      .where("orders.status = ?", 2)
      .group(:id)
      .order("total_items DESC")
      .first
  end

  def top_3_spenders
    User
      .select("users.*, sum(order_items.quantity * order_items.price_per_item) as total_spent")
      .joins(orders: :items)
      .where("items.user_id = ?", self.id)
      .where("users.active = ?", true)
      .where('order_items.fulfilled = ?', true)
      .where("orders.status = ?", 2)
      .group(:id)
      .order("total_spent DESC")
      .limit(3)
  end

  def downgrade_to_regular_user
    update(role: "user")
    items.update_all(active: false)
  end
end
