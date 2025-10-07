class Cancellation < ApplicationRecord
  belongs_to :user
  belongs_to :slot

  validates :week_start, presence: true
  validates :user_id, uniqueness: { scope: [:slot_id, :week_start], message: 'already has a cancellation for this slot and week' }

  scope :for_week, ->(week_start) { where(week_start: week_start) }

  def cancel!
    destroy!
  end
end
