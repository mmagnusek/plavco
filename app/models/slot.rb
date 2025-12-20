class Slot < ApplicationRecord
  DAYS_OF_WEEK = [1,2,3,4,5].freeze

  belongs_to :trainer
  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings
  has_many :cancellations, dependent: :destroy
  has_many :regular_attendees, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy
  has_many :regular_users, through: :regular_attendees, source: :user do
    def for_week(week_start)
      @for_week_cache ||= {}
      @for_week_cache[week_start] ||= begin
        where(id: proxy_association.owner.regular_attendees.for_week(week_start).pluck(:user_id).uniq)
      end
    end
  end

  validates :day_of_week, presence: true, inclusion: { in: 1..5 } # 0 = Sunday, 1 = Monday, etc.
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :max_participants, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }
  validate :ends_after_starts
  validate :valid_time_slot

  scope :ordered_by_day_and_time, -> { order(day_of_week: :asc, starts_at: :asc) }

  def broadcast_update(week_start)
    message = "Calendar updated for week of #{week_start.strftime('%B %d, %Y')}"
    broadcast_prepend_later_to "calendar_#{week_start.strftime('%Y-%m-%d')}",
      target: 'flash-container',
      partial: 'shared/flash_message',
      locals: { message:, type: 'info' }

    broadcast_append_later_to "calendar_#{week_start.strftime('%Y-%m-%d')}",
      partial: 'shared/refresh_slot_script',
      target: 'flash-container',
      locals: { slot_id: id, week_start: }

    @participants_for_week_cache&.delete(week_start)

    unless fully_booked_for_week?(week_start)
      waitlist_entries.for_week(week_start).find_each do |waitlist_entry|
        UserMailer.with(user: waitlist_entry.user, slot: self, week_start:).notify_free_spot.deliver_later
      end
    end
  end

  def day_name
    I18n.translate("date.day_names")[day_of_week]
  end

  def duration_minutes
    ((ends_at - starts_at) / 1.minute).round
  end

  def available_spots_for_week(week_start = Date.current.beginning_of_week)
    max_participants - participants_for_week(week_start).count
  end

  def fully_booked_for_week?(week_start = Date.current.beginning_of_week)
    available_spots_for_week(week_start) <= 0
  end

  def start_time(week_start = Date.current.beginning_of_week)
    date = week_start + day_of_week.days
    date -= 1.day if week_start.monday?

    Time.zone.parse("#{date} #{starts_at.strftime('%H:%M')}")
  end

  def last_possible_modification_at(week_start = Date.current.beginning_of_week)
    (start_time(week_start) - 1.day).change(hour: 17)
  end

  def can_book_for_week?(user, week_start = Date.current.beginning_of_week)
    return false if start_time(week_start).past?
    return false if fully_booked_for_week?(week_start)
    return false if participants_for_week(week_start).any? { |p| p[:user].id == user.id }
    true
  end

  def can_waiting_list_for_week?(user, week_start = Date.current.beginning_of_week)
    return false if start_time(week_start).past?
    return false if participants_for_week(week_start).any? { |p| p[:user].id == user.id }
    return false if waiting_for_week_entry(user, week_start).present?
    true
  end

  def waiting_for_week_entry(user, week_start = Date.current.beginning_of_week)
    waitlist_entries.for_week(week_start).find_by(user:)
  end

  def participants_for_week(week_start = Date.current.beginning_of_week)
    @participants_for_week_cache ||= {}
    @participants_for_week_cache[week_start] ||= begin
      regular_users.for_week(week_start).where.not(id: cancellations.for_week(week_start).select(:user_id)).map { |u| { user: u, type: 'regular' } } +
        bookings.for_week(week_start).preload(:user).map { |b| { user: b.user, type: 'temporary', booking: b } }
    end
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
