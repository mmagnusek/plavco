class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :slot
  belongs_to :cancelled_from, class_name: 'Cancellation', optional: true

  validates :week_start, presence: true
  validates :user_id, uniqueness: { scope: [:slot_id, :week_start], message: 'has already booked this slot for this week' }
  validate :slot_has_availability_for_week
  validate :slot_not_in_past
  validate :week_start_is_valid

  scope :upcoming, -> { joins(:slot).where('slots.starts_at > ?', Time.current) }
  scope :past, -> { joins(:slot).where('slots.starts_at <= ?', Time.current) }
  scope :for_week, ->(week_start) { where(week_start: week_start) }

  # Turbo Stream broadcasting for real-time updates
  after_create_commit -> { broadcast_slot_update }
  after_update_commit -> { broadcast_slot_update }
  after_destroy_commit -> { broadcast_slot_update }

  def last_possible_modification_at
    slot.last_possible_modification_at(week_start)
  end

  private

  def broadcast_slot_update
    if previous_changes.include?(:slot_id)
      Slot.find_by(id: previous_changes[:slot_id].first)&.broadcast_update(week_start)
    end
    slot.broadcast_update(week_start)
  end

  def slot_has_availability_for_week
    return unless slot && week_start

    errors.add(:slot, 'is fully booked for this week') if slot.fully_booked_for_week?(week_start)
  end

  def slot_not_in_past
    return unless slot && week_start

    errors.add(:slot, 'cannot be booked for past time slots') if slot.start_time(week_start).past?
  end

  def week_start_is_valid
    return unless week_start

    errors.add(:week_start, 'must be a Monday') unless week_start.monday?
  end
end
