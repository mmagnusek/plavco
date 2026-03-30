# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @slot = @invitation.slot

    mail to: @invitation.email, subject: default_i18n_subject
  end
end
