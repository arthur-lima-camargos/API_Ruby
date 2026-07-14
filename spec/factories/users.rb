FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "produtor#{n}@example.com" }
    password { "password123" }
  end
end
