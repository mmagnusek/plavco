# frozen_string_literal: true

class InvitationsController < ApplicationController
  allow_unauthenticated_access only: [:show]

  def show
    @invitation = Invitation.find_by(token: params[:token])
    unless @invitation
      redirect_to new_session_path, alert: t('flashes.invitations.not_found')
      return
    end

    if @invitation.invalid_for_registration_reason
      @invalid_reason = @invitation.invalid_for_registration_reason
      render :ineligible
      return
    end

    if authenticated?
      @slot = @invitation.slot
      @trainer_name = @slot.trainer.name
      if current_user.email_address == @invitation.email
        render :show
      else
        @email_mismatch = true
        render :show
      end
      return
    end

    redirect_to new_registration_path(invitation_token: @invitation.token)
  end

  def accept
    @invitation = Invitation.find_by(token: params[:token])
    unless @invitation
      redirect_to root_path, alert: t('flashes.invitations.not_found')
      return
    end

    unless @invitation.usable?
      redirect_to invitation_path(@invitation.token), alert: t('flashes.invitations.unusable')
      return
    end

    unless current_user.email_address == @invitation.email
      redirect_to invitation_path(@invitation.token), alert: t('flashes.invitations.wrong_account')
      return
    end

    InvitationAcceptance.call!(invitation: @invitation, user: current_user)
    Current.session&.update(trainer: @invitation.slot.trainer)
    redirect_to root_path, notice: t('flashes.invitations.accepted')
  rescue ActiveRecord::RecordInvalid => e
    redirect_to invitation_path(@invitation.token), alert: e.record.errors.full_messages.to_sentence
  end
end
