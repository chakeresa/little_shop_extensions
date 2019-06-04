FactoryBot.define do
  factory :bulk_discount do
    user
    sequence(:bulk_quantity) { |n| ("#{n}".to_i+1)*2 }
    sequence(:pc_off) { |n| ("#{n}".to_i+1)*1.5 }
  end
end
