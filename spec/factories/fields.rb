FactoryBot.define do
  factory :field do
    sequence(:name) { |n| "Talhão #{n}" }
    crop { %w[Soja Milho Café Cana Algodão].sample }
    association :farm
  end
end
