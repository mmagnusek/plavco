class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :week_start, presence: true
  validates :user_id, uniqueness: { scope: [:slot_id, :week_start], message: 'has already booked this slot for this week' }
  validate :slot_has_availability_for_week
  validate :slot_not_in_past
  validate :week_start_is_valid

  scope :upcoming, -> { joins(:slot).where('slots.starts_at > ?', Time.current) }
  scope :past, -> { joins(:slot).where('slots.starts_at <= ?', Time.current) }
  scope :for_week, ->(week_start) { where(week_start: week_start) }

  def cancel!
    destroy!
  end

  def can_cancel?
    slot.starts_at > Time.current
  end

  private

  def slot_has_availability_for_week
    return unless slot && week_start

    if slot.fully_booked_for_week?(week_start)
      errors.add(:slot, 'is fully booked for this week')
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

  def week_start_is_valid
    return unless week_start

    unless week_start.wday == 1
      errors.add(:week_start, 'must be a Monday')
    end
  end
end
