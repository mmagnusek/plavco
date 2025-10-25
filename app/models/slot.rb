class Slot < ApplicationRecord
  DAYS_OF_WEEK = {
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
  }.freeze

  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings
  has_many :cancellations, dependent: :destroy
  has_many :regular_attendees, dependent: :destroy
  has_many :regular_users, through: :regular_attendees, source: :user

  validates :day_of_week, presence: true, inclusion: { in: 1..5 } # 0 = Sunday, 1 = Monday, etc.
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :max_participants, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validate :ends_after_starts
  validate :valid_time_slot

  scope :ordered_by_day_and_time, -> { order(day_of_week: :asc, starts_at: :asc) }

  def broadcast_update(week_start)
    message = "Calendar updated for week of #{week_start.strftime('%B %d, %Y')}"
    broadcast_prepend_later_to 'calendar',
      target: 'flash-container',
      partial: 'shared/flash_message',
      locals: { message:, type: 'info' }
  end

  def day_name
    DAYS_OF_WEEK[day_of_week]
  end

  def duration_minutes
    ((ends_at - starts_at) / 1.minute).round
  end

  def available_spots_for_week(week_start = Date.current.beginning_of_week)
    @available_spots_for_week ||= {}
    @available_spots_for_week[week_start] ||= begin
      # Count regular attendees who are NOT cancelled this week
      attending_regulars = regular_users.count - cancellations.where(week_start: week_start).count

      # Count temporary bookings for this week
      temporary_bookings = bookings.for_week(week_start).count

        max_participants - attending_regulars - temporary_bookings
    end
  end

  def fully_booked_for_week?(week_start = Date.current.beginning_of_week)
    available_spots_for_week(week_start) <= 0
  end

  def past?(week_start = Date.current.beginning_of_week)
    date = week_start + day_of_week.days
    date -= 1.day if week_start.monday?

    Time.zone.parse("#{date} #{starts_at.strftime('%H:%M')}").past?
  end

  def can_book_for_week?(user, week_start = Date.current.beginning_of_week)
    return false if past?(week_start)
    return false if fully_booked_for_week?(week_start)
    return false if regular_users.include?(user) && !cancelled_this_week?(user, week_start)
    return false if bookings.exists?(user: user, week_start: week_start)
    true
  end

  def cancelled_this_week?(user, week_start = Date.current.beginning_of_week)
    cancellations.exists?(user: user, week_start: week_start)
  end

  def participants_for_week(week_start = Date.current.beginning_of_week)
    participants = []

    # Add regular attendees who are not cancelled
    regular_users.includes(:cancellations).each do |user|
      unless cancelled_this_week?(user, week_start)
        participants << { user: user, type: 'regular' }
      end
    end

    # Add temporary bookings for this week
    bookings.for_week(week_start).includes(:user).each do |booking|
      participants << { user: booking.user, type: 'temporary', booking: booking }
    end

    participants
  end

  def time_range
    "#{starts_at.strftime('%H:%M')} - #{ends_at.strftime('%H:%M')}"
  end

  def to_label
    "#{day_name} #{time_range}"
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
