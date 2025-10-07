# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample users (swimming participants)
users = [
  { name: "Alice Johnson", email: "alice@example.com", phone: "+1234567890" },
  { name: "Bob Smith", email: "bob@example.com", phone: "+1234567891" },
  { name: "Carol Davis", email: "carol@example.com", phone: "+1234567892" },
  { name: "David Wilson", email: "david@example.com", phone: "+1234567893" },
  { name: "Eva Brown", email: "eva@example.com", phone: "+1234567894" }
]

users.each do |user_attrs|
  User.find_or_create_by!(email: user_attrs[:email]) do |user|
    user.name = user_attrs[:name]
    user.phone = user_attrs[:phone]
  end
end

# Create weekly swimming training slots (45 minutes each)
# Monday to Friday, 9:00 AM - 9:45 AM, max 4 participants each
weekdays = [1, 2, 3, 4, 5] # Monday to Friday
start_time = Time.zone.parse("08:00")
end_time = Time.zone.parse("08:45")

weekdays.each do |day_of_week|
  Slot.find_or_create_by!(day_of_week: day_of_week, starts_at: start_time) do |slot|
    slot.ends_at = end_time
    slot.max_participants = 4
  end
end

# Create additional slots for different times
# Tuesday and Thursday, 6:00 PM - 6:45 PM
evening_days = [2, 4] # Tuesday and Thursday
evening_start = Time.zone.parse("17:00")
evening_end = Time.zone.parse("17:45")

evening_days.each do |day_of_week|
  Slot.find_or_create_by!(day_of_week: day_of_week, starts_at: evening_start) do |slot|
    slot.ends_at = evening_end
    slot.max_participants = 3
  end
end

# Create regular attendees for slots
puts "Creating regular attendees..."

# Alice is a regular attendee for Monday morning slot
monday_morning = Slot.find_by(day_of_week: 1, starts_at: Time.zone.parse("08:00"))
RegularAttendee.find_or_create_by!(user: User.find_by(email: "alice@example.com"), slot: monday_morning)
puts "Alice is a regular attendee for Monday morning"

# Bob is a regular attendee for Tuesday morning slot
tuesday_morning = Slot.find_by(day_of_week: 2, starts_at: Time.zone.parse("08:00"))
RegularAttendee.find_or_create_by!(user: User.find_by(email: "bob@example.com"), slot: tuesday_morning)
puts "Bob is a regular attendee for Tuesday morning"

# Carol is a regular attendee for Wednesday morning slot
wednesday_morning = Slot.find_by(day_of_week: 3, starts_at: Time.zone.parse("08:00"))
RegularAttendee.find_or_create_by!(user: User.find_by(email: "carol@example.com"), slot: wednesday_morning)
puts "Carol is a regular attendee for Wednesday morning"

# David is a regular attendee for Thursday evening slot
thursday_evening = Slot.find_by(day_of_week: 4, starts_at: Time.zone.parse("17:00"))
RegularAttendee.find_or_create_by!(user: User.find_by(email: "david@example.com"), slot: thursday_evening)
puts "David is a regular attendee for Thursday evening"

# Eva is a regular attendee for Friday morning slot
friday_morning = Slot.find_by(day_of_week: 5, starts_at: Time.zone.parse("08:00"))
RegularAttendee.find_or_create_by!(user: User.find_by(email: "eva@example.com"), slot: friday_morning)
puts "Eva is a regular attendee for Friday morning"

puts "Seeded #{User.count} users, #{Slot.count} training slots, and #{RegularAttendee.count} regular attendees"
