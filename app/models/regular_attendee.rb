class RegularAttendee < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :user_id, uniqueness: { scope: :slot_id, message: 'is already a regular attendee for this slot' }
end
