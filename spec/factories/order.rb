FactoryBot.define do
  factory :order, class: Order do
    user
    address
    status { :pending }
  end
  factory :packaged_order, parent: :order do
    user
    address
    status { :packaged }
  end
  factory :shipped_order, parent: :order do
    user
    address
    status { :shipped }
  end
  factory :cancelled_order, parent: :order do
    user
    address
    status { :cancelled }
  end
end
