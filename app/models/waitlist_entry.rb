class WaitlistEntry < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :week_start, presence: true
  validates :user_id, uniqueness: { scope: [:slot_id, :week_start], message: 'has already joined the waitlist for this slot and week' }
  validate :week_start_is_valid

  scope :for_week, ->(week_start) { where(week_start: week_start) }

  private

  def week_start_is_valid
    return unless week_start

    errors.add(:week_start, 'must be a Monday') unless week_start.monday?
  end
end
