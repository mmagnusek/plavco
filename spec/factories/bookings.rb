FactoryBot.define do
  factory :booking do
    user
    slot
    week_start { Date.current.beginning_of_week }

    trait :with_cancellation do
      after(:create) do |booking|
        create(:cancellation, booking: booking)
      end
    end
  end
end
