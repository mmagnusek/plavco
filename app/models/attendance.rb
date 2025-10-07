class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :week_start, presence: true
  validates :attending, inclusion: { in: [true, false] }
  validates :user_id, uniqueness: { scope: [:slot_id, :week_start], message: 'already has attendance record for this slot and week' }

  scope :attending, -> { where(attending: true) }
  scope :not_attending, -> { where(attending: false) }
  scope :for_week, ->(week_start) { where(week_start: week_start) }

  def toggle_attendance!
    update!(attending: !attending)
  end

  def attending?
    attending
  end

  def not_attending?
    !attending
  end
end
