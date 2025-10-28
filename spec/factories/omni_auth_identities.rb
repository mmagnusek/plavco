FactoryBot.define do
  factory :omni_auth_identity do
    provider { 'google_oauth2' }
    uid { Faker::Internet.uuid }
    user
  end
end
