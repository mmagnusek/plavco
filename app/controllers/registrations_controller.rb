# frozen_string_literal: true

class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_authenticated, only: [:new]
  rate_limit to: 10, within: 5.minutes, only: :create, with: -> { redirect_to new_session_path, alert: t('flashes.invitations.try_again_later') }

  def new
    if params[:invitation_token].present?
      @invitation = Invitation.find_by(token: params[:invitation_token])
      unless @invitation
        redirect_to new_session_path, alert: t('flashes.invitations.not_found')
        return
      end

      if @invitation.invalid_for_registration_reason
        redirect_to invitation_path(@invitation.token)
        return
      end

      session[:invitation_token] = @invitation.token
      @user = User.new(email_address: @invitation.email, name: @invitation.name.presence)
    else
      @user = User.new
    end
  end

  def create
    if params[:invitation_token].present?
      create_with_invitation
    else
      create_without_invitation
    end
  end

  private

  def redirect_if_authenticated
    redirect_to after_authentication_url if authenticated?
  end

  def create_with_invitation
    @invitation = Invitation.find_by(token: params[:invitation_token])
    unless @invitation
      redirect_to new_session_path, alert: t('flashes.invitations.not_found')
      return
    end

    if @invitation.invalid_for_registration_reason
      redirect_to invitation_path(@invitation.token), alert: t('flashes.invitations.unusable')
      return
    end

    if User.exists?(email_address: @invitation.email)
      session[:return_to_after_authenticating] = invitation_path(@invitation.token)
      redirect_to new_session_path, alert: t('flashes.invitations.email_taken')
      return
    end

    @user = build_user_from_invitation
    if @user.save
      InvitationAcceptance.call!(invitation: @invitation, user: @user)
      session.delete(:invitation_token)
      start_new_session_for(@user)
      redirect_to root_path, notice: t('flashes.invitations.registered')
    else
      render :new, status: :unprocessable_content
    end
  end

  def create_without_invitation
    @invitation = nil
    @user = User.new(open_registration_params.merge(locale: I18n.default_locale.to_s))
    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: t('flashes.registrations.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  def build_user_from_invitation
    attrs = invitation_registration_params
    User.new(
      email_address: @invitation.email,
      name: attrs[:name].presence || @invitation.name,
      password: attrs[:password],
      password_confirmation: attrs[:password_confirmation],
      locale: I18n.default_locale.to_s
    )
  end

  def invitation_registration_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def open_registration_params
    params.require(:user).permit(:email_address, :name, :password, :password_confirmation)
  end
end
