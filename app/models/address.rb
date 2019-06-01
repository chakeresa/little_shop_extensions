class Address < ApplicationRecord
  has_many :orders
  # belongs_to :user
  belongs_to :user, class_name: 'User'

  validates_presence_of :nickname,
                        :street,
                        :city,
                        :state,
                        :zip
end