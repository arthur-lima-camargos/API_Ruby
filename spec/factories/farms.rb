FactoryBot.define do
  factory :farm do
    name { "Fazenda #{Faker::Address.city}" }
    location { Faker::Address.state }
    association :user
  end
end
