FactoryBot.define do
  factory :sensor do
    sensor_type { :humidity }
    association :field
  end
end
