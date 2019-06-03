class Address < ApplicationRecord
  has_many :orders
  belongs_to :user, class_name: 'User'

  validates_presence_of :nickname,
                        :street,
                        :city,
                        :state,
                        :zip

  def no_completed_orders?
    Order.where(address_id: id).where(status: ["shipped", "packaged"]).count == 0
  end

  def delete_addr_and_associations
    user.update(primary_address_id: nil)
    orders.clear
    destroy
  end
end