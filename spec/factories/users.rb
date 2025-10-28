FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
    phone { '+420123456789' }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :with_omniauth_identity do
      after(:create) do |user|
        create(:omni_auth_identity, user: user)
      end
    end
  end
end
