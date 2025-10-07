class Slot < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings

  validates :day_of_week, presence: true, inclusion: { in: 0..6 } # 0 = Sunday, 1 = Monday, etc.
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :max_participants, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validate :ends_after_starts
  validate :valid_time_slot

  DAYS_OF_WEEK = {
    0 => 'Sunday',
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday'
  }.freeze

  def day_name
    DAYS_OF_WEEK[day_of_week]
  end

  def duration_minutes
    ((ends_at - starts_at) / 1.minute).round
  end

  def available_spots
    max_participants - bookings.count
  end

  def fully_booked?
    available_spots <= 0
  end

  def can_book?(user)
    return false if fully_booked?
    return false if users.include?(user)
    true
  end

  def time_range
    "#{starts_at.strftime('%H:%M')} - #{ends_at.strftime('%H:%M')}"
  end

  private

  def ends_after_starts
    return unless starts_at && ends_at

    if ends_at <= starts_at
      errors.add(:ends_at, 'must be after start time')
    end
  end

  def valid_time_slot
    return unless starts_at && ends_at

    duration = duration_minutes
    if duration != 45
      errors.add(:ends_at, 'slot must be exactly 45 minutes long')
    end
  end
end
