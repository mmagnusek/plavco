# frozen_string_literal: true

FactoryBot.define do
  factory :invitation do
    slot
    sequence(:email) { |n| "invited#{n}@example.com" }
    from { Date.current }
    name { 'Invited User' }
  end
end
