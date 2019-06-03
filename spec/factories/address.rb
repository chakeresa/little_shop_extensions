FactoryBot.define do
  factory :address, class: Address do
    association :user, factory: :user
    sequence(:nickname) { |n| "Nickname #{n}" }
    sequence(:street) { |n| "Street Address #{n}" }
    sequence(:city) { |n| "City #{n}" }
    sequence(:state) { |n| "State #{n}" }
    sequence(:zip) { |n| "Zip #{n}" }
  end
end
