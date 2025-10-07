class Slot < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings
  has_many :attendances, dependent: :destroy
  has_many :regular_participants, through: :attendances, source: :user

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

  def available_spots_for_week(week_start = Date.current.beginning_of_week)
    # Count regular participants who are attending this week
    attending_regulars = attendances.where(week_start: week_start, attending: true).count

    # Count temporary bookings for this week
    # These are bookings from users who either:
    # 1. Are not regular participants for this slot, OR
    # 2. Are regular participants but marked as not attending this week
    temporary_bookings = bookings.count

    max_participants - attending_regulars - temporary_bookings
  end

  def fully_booked_for_week?(week_start = Date.current.beginning_of_week)
    available_spots_for_week(week_start) <= 0
  end

  def can_book_for_week?(user, week_start = Date.current.beginning_of_week)
    return false if fully_booked_for_week?(week_start)
    return false if user_attending_this_week?(user, week_start)
    return false if user_has_temporary_booking?(user, week_start)
    true
  end

  def user_attending_this_week?(user, week_start = Date.current.beginning_of_week)
    attendances.exists?(user: user, week_start: week_start, attending: true)
  end

  def user_has_temporary_booking?(user, week_start = Date.current.beginning_of_week)
    # Check if user has a temporary booking for this week
    bookings.exists?(user: user)
  end

  def participants_for_week(week_start = Date.current.beginning_of_week)
    attending_users = []

    # Add regular participants who are attending
    attendances.includes(:user).where(week_start: week_start, attending: true).each do |attendance|
      attending_users << { user: attendance.user, type: 'regular' }
    end

    # Add temporary bookings
    bookings.includes(:user).each do |booking|
      attending_users << { user: booking.user, type: 'temporary' }
    end

    attending_users
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
