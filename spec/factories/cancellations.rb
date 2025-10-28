FactoryBot.define do
  factory :cancellation do
    booking
    user { booking.user }
    slot { booking.slot }
    week_start { Date.current.beginning_of_week }
  end
end
