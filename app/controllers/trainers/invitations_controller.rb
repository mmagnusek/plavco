# frozen_string_literal: true

module Trainers
  class InvitationsController < Trainers::ApplicationController
    before_action :set_slot

    def create
      @invitation = @slot.invitations.build(invitation_params)
      authorize! :create, @invitation

      normalized_email = @invitation.email.to_s.strip.downcase
      if @slot.trainer.users.exists?(email_address: normalized_email)
        redirect_to trainer_slot_path(@slot), alert: t('flashes.trainers.invitations.email_taken')
        return
      end

      if @invitation.save
        InvitationMailer.with(invitation: @invitation).invite.deliver_later
        redirect_to trainer_slot_path(@slot), notice: t('flashes.trainers.invitations.sent')
      else
        redirect_to trainer_slot_path(@slot), alert: @invitation.errors.full_messages.to_sentence
      end
    end

    def destroy
      @invitation = @slot.invitations.pending.find(params[:id])
      authorize! :destroy, @invitation
      @invitation.destroy
      redirect_to trainer_slot_path(@slot), notice: t('flashes.trainers.invitations.cancelled')
    end

    private

    def set_slot
      @slot = current_user.trainer.slots.find(params[:slot_id])
    end

    def invitation_params
      params.require(:invitation).permit(:email, :from, :name)
    end
  end
end
