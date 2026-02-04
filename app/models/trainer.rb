class Trainer < ApplicationRecord
  has_many :slots
  has_many :cancellations, through: :slots
  has_many :bookings, through: :slots
  has_many :regular_attendees, through: :slots
  has_many :waitlist_entries, through: :slots
  has_and_belongs_to_many :users
end
