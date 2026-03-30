# frozen_string_literal: true

class InvitationAcceptance
  def self.call!(invitation:, user:)
    ActiveRecord::Base.transaction do
      trainer = invitation.slot.trainer
      user.trainers << trainer unless user.trainers.exists?(trainer.id)
      RegularAttendee.create!(user:, slot: invitation.slot, from: invitation.from)
      invitation.update!(accepted_at: Time.current)
    end
  end
end
