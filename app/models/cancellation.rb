class Cancellation < ApplicationRecord
  belongs_to :user
  belongs_to :slot
  has_one :booking, foreign_key: 'cancelled_from_id', dependent: :nullify

  validates :week_start, presence: true
  validates :user_id, uniqueness: { scope: [:slot_id, :week_start], message: 'already has a cancellation for this slot and week' }

  scope :for_week, ->(week_start) { where(week_start: week_start) }

  # Turbo Stream broadcasting for real-time updates
  after_create_commit -> { broadcast_slot_update }

  private

  def broadcast_slot_update
    slot.broadcast_update(week_start)
  end
end
