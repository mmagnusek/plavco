# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database with current data..."

# Create users from current database
users_data = [
  { name: 'John Doe', email_address: 'john@plavci.cz', phone: '+420775032668', password: '#password123#', admin: true },
  { name: 'Jane Doe', email_address: 'jane@plavci.cz', phone: '+420775032669', password: '#password123#', admin: false }
]

trainer = Trainer.create!(name: 'Plavco')

users = users_data.map do |user_attrs|
  User.where(email_address: user_attrs[:email_address]).first_or_create!(user_attrs)
end

users.each do |user|
  user.trainers << trainer
end

puts "Created/updated #{User.count} users"

# Create slots from current database (focus on slots table as requested)
slots_data = [
  # Tuesday slots
  { day_of_week: 2, starts_at: '06:00', ends_at: '06:45', max_participants: 4, regular_users: [users[0]] },
  { day_of_week: 2, starts_at: '06:45', ends_at: '07:30', max_participants: 4, regular_users: [users[1]] },
  { day_of_week: 2, starts_at: '07:30', ends_at: '08:15', max_participants: 4 },
  { day_of_week: 2, starts_at: '08:15', ends_at: '09:00', max_participants: 4 },

  # Wednesday slots
  { day_of_week: 3, starts_at: '06:45', ends_at: '07:30', max_participants: 4, regular_users: [users[0]] },
  { day_of_week: 3, starts_at: '07:30', ends_at: '08:15', max_participants: 4, regular_users: [users[1]] },
  { day_of_week: 3, starts_at: '18:00', ends_at: '18:45', max_participants: 4 },
  { day_of_week: 3, starts_at: '18:45', ends_at: '19:30', max_participants: 4 },

  # Friday slots
  { day_of_week: 5, starts_at: '06:00', ends_at: '06:45', max_participants: 4, regular_users: [users[0]] },
  { day_of_week: 5, starts_at: '06:45', ends_at: '07:30', max_participants: 4, regular_users: [users[1]] },
  { day_of_week: 5, starts_at: '07:30', ends_at: '08:15', max_participants: 4 },
  { day_of_week: 5, starts_at: '08:15', ends_at: '09:00', max_participants: 4 }
]

users = User.all.to_a

slots_data.each do |slot_attrs|
  slot = trainer.slots.find_or_create_by!(day_of_week: slot_attrs[:day_of_week], starts_at: Time.zone.parse(slot_attrs[:starts_at])) do |s|
    s.ends_at = Time.zone.parse(slot_attrs[:ends_at])
    s.max_participants = slot_attrs[:max_participants]
  end

  Array(slot_attrs[:regular_users]).each do |user|
    slot.regular_attendees.find_or_create_by!(user: user) do |attendee|
      attendee.from = Date.current.beginning_of_week
    end
  end
end

puts "Created/updated #{Slot.count} training slots"

puts "Seeding completed successfully!"
