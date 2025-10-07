class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :user_id, uniqueness: { scope: :slot_id, message: 'has already booked this slot' }
  validate :slot_has_availability
  validate :slot_not_in_past

  scope :upcoming, -> { joins(:slot).where('slots.starts_at > ?', Time.current) }
  scope :past, -> { joins(:slot).where('slots.starts_at <= ?', Time.current) }

  def cancel!
    destroy!
  end

  def can_cancel?
    slot.starts_at > Time.current
  end

  private

  def slot_has_availability
    return unless slot

    if slot.fully_booked?
      errors.add(:slot, 'is fully booked')
    end
  end

  def slot_not_in_past
    return unless slot

    # For weekly recurring slots, check if the time has passed today
    # Only prevent booking if it's the same day and the time has passed
    today = Date.current
    slot_time_today = Time.zone.parse("#{today} #{slot.starts_at.strftime('%H:%M')}")

    # Only validate if it's the same day of the week and the time has passed
    if today.wday == slot.day_of_week && slot_time_today <= Time.current
      errors.add(:slot, 'cannot be booked for past time slots')
    end
  end
end
