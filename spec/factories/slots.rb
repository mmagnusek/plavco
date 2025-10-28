FactoryBot.define do
  factory :slot do
    starts_at { '10:00:00' }
    ends_at { '10:45:00' }
    max_participants { 10 }
    day_of_week { 1 } # Monday

    trait :with_bookings do
      after(:create) do |slot|
        create_list(:booking, 3, slot: slot)
      end
    end

    trait :full do
      after(:create) do |slot|
        slot.max_participants.times do
          create(:booking, slot: slot)
        end
      end
    end
  end
end
