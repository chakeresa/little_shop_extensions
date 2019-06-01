class Address < ApplicationRecord
  has_many :orders 
  belongs_to :user

  validates_presence_of :nickname,
                        :street,
                        :city,
                        :state,
                        :zip
end