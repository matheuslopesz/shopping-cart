FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    abandoned { false }
    last_interaction_at { Time.current }

    trait :abandoned do
      last_interaction_at { 4.hours.ago }
      abandoned { true }
    end
  end
end