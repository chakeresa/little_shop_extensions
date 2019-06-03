class BulkDiscount < ApplicationRecord
  belongs_to :user

  validates :bulk_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :pc_off, numericality: { greater_than_or_equal_to: 0.01 }
end
