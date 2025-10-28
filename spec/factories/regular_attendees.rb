FactoryBot.define do
  factory :regular_attendee do
    user
    slot
    week_start { Date.current.beginning_of_week }
  end
end
