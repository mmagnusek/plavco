class RegularAttendee < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validate :to_after_from
  validates :from, presence: true
  validate :uniqueness_of_regular_attendee

  scope :for_week, ->(week_start) { within_time_range(week_start, week_start.end_of_week) }
  scope :within_time_range, ->(from, to) {
    table = arel_table

    if from && to
      where(table[:from].lteq(to).and(table[:to].eq(nil).or(table[:to].gteq(from))))
    elsif from
      where(table[:to].eq(nil).or(table[:to].gteq(from)))
    elsif to
      where(table[:from].lteq(to))
    else
      all
    end
  }

  private

  def to_after_from
    errors.add(:to, 'must be after from') if from && to && to <= from
  end

  def uniqueness_of_regular_attendee
    return unless user_id && slot_id

    overlapping = RegularAttendee.where(user_id:, slot_id:).within_time_range(from, to)
    overlapping = overlapping.where.not(id: id) if persisted?
    errors.add(:user_id, 'is already a regular attendee for this slot') if overlapping.any?
  end
end
