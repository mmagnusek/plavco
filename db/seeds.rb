# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database with current data..."

# Create users from current database
users_data = [
  { name: 'Alice Johnson', email: 'alice@example.com', phone: '+1234567890', admin: false },
  { name: 'Bob Smith', email: 'bob@example.com', phone: '+1234567891', admin: false },
  { name: 'Carol Davis', email: 'carol@example.com', phone: '+1234567892', admin: false },
  { name: 'Martin Magnusek', email: 'magnusekm@gmail.com', phone: '+420775032668', admin: true },
  { name: 'Eliška Magnusková', email: 'eliskamagnuskova@gmail.com', phone: '+420605854230', admin: false },
  { name: 'Admin User', email: 'admin@example.com', phone: '+1234567899', admin: true },
  { name: 'David Wilson', email: 'david@example.com', phone: '+1234567893', admin: false },
  { name: 'Eva Brown', email: 'eva@example.com', phone: '+1234567894', admin: false }
]

users_data.each do |user_attrs|
  User.find_or_create_by!(email: user_attrs[:email]) do |user|
    user.name = user_attrs[:name]
    user.phone = user_attrs[:phone]
    user.admin = user_attrs[:admin]
  end
end

puts "Created/updated #{User.count} users"

# Create slots from current database (focus on slots table as requested)
slots_data = [
  # Tuesday slots
  { day_of_week: 2, starts_at: '06:00', ends_at: '06:45', max_participants: 4 },
  { day_of_week: 2, starts_at: '06:45', ends_at: '07:30', max_participants: 4 },
  { day_of_week: 2, starts_at: '07:30', ends_at: '08:15', max_participants: 4 },
  { day_of_week: 2, starts_at: '08:15', ends_at: '09:00', max_participants: 4 },
  { day_of_week: 2, starts_at: '09:00', ends_at: '09:45', max_participants: 4 },

  # Wednesday slots
  { day_of_week: 3, starts_at: '06:45', ends_at: '07:30', max_participants: 4 },
  { day_of_week: 3, starts_at: '07:30', ends_at: '08:15', max_participants: 4 },
  { day_of_week: 3, starts_at: '08:15', ends_at: '09:00', max_participants: 4 },
  { day_of_week: 3, starts_at: '16:30', ends_at: '17:15', max_participants: 4 },
  { day_of_week: 3, starts_at: '17:15', ends_at: '18:00', max_participants: 4 },
  { day_of_week: 3, starts_at: '18:00', ends_at: '18:45', max_participants: 4 },
  { day_of_week: 3, starts_at: '18:45', ends_at: '19:30', max_participants: 4 },
  { day_of_week: 3, starts_at: '19:30', ends_at: '20:15', max_participants: 4 },

  # Friday slots
  { day_of_week: 5, starts_at: '06:00', ends_at: '06:45', max_participants: 4 },
  { day_of_week: 5, starts_at: '06:45', ends_at: '07:30', max_participants: 4 },
  { day_of_week: 5, starts_at: '07:30', ends_at: '08:15', max_participants: 4 },
  { day_of_week: 5, starts_at: '08:15', ends_at: '09:00', max_participants: 4 },
  { day_of_week: 5, starts_at: '09:00', ends_at: '09:45', max_participants: 4 }
]

users = User.all.to_a

slots_data.each do |slot_attrs|
  Slot.find_or_create_by!(day_of_week: slot_attrs[:day_of_week], starts_at: Time.zone.parse(slot_attrs[:starts_at])) do |slot|
    slot.ends_at = Time.zone.parse(slot_attrs[:ends_at])
    slot.max_participants = slot_attrs[:max_participants]

    slot.regular_users << users.sample(slot_attrs[:max_participants])
  end
end

puts "Created/updated #{Slot.count} training slots"

puts "Seeding completed successfully!"
