class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create omni_auth_create omni_auth_failure]
  before_action :redirect_authenticated_user, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: t('flashes.auth.try_again_later') }

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t('flashes.auth.try_another_credentials')
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  def omni_auth_create
    auth = request.env['omniauth.auth']
    uid = auth['uid']
    provider = auth['provider']
    redirect_path = request.env['omniauth.params']&.dig('origin') || root_path

    identity = OmniAuthIdentity.find_by(uid: uid, provider: provider)
    if authenticated?
      # User is signed in so they are trying to link an identity with their account
      if identity.nil?
        # No identity was found, create a new one for this user
        OmniAuthIdentity.create(uid: uid, provider: provider, user: Current.user)
        # Give the user model the option to update itself with the new information
        Current.user.signed_in_with_oauth(auth)
        redirect_to after_authentication_url, notice: t('flashes.auth.account_linked')
      else
        # Identity was found, nothing to do
        # Check relation to current user
        if Current.user == identity.user
          redirect_to after_authentication_url, notice: t('flashes.auth.already_linked')
        else
          # The identity is not associated with the current_user, illegal state
          redirect_to redirect_path, notice: t('flashes.auth.account_mismatch')
        end
      end
    else
      # Check if identity was found i.e. user has visited the site before
      if identity.nil?
        # New identity visiting the site, we are linking to an existing User or creating a new one
        user = User.find_by(email_address: auth.info.email) || User.create_from_oauth(auth)
        identity = OmniAuthIdentity.create(uid: uid, provider: provider, user: user)
      end
      start_new_session_for identity.user
              redirect_to after_authentication_url, notice: t('flashes.auth.signed_in')
    end
  end

  def omni_auth_failure
    redirect_to new_session_path, alert: t('flashes.auth.authentication_failed')
  end

  private

  def redirect_authenticated_user
    redirect_to after_authentication_url if authenticated?
  end
end
