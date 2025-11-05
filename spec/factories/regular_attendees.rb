FactoryBot.define do
  factory :regular_attendee do
    user
    slot
    from { Date.current.beginning_of_week }
  end
end
