FactoryBot.define do
  factory :reading do
    value { 45.2 }
    recorded_at { Time.current }
    association :sensor
  end
end
