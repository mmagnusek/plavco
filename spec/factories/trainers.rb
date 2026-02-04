FactoryBot.define do
  factory :trainer do
    sequence(:name) { |n| "Trainer #{n}" }
  end
end
