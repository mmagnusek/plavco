# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invitations' do
  let(:trainer) { create(:trainer) }
  let(:slot) { create(:slot, trainer: trainer) }
  let(:invitation) { create(:invitation, slot: slot, email: 'join@example.com', name: 'Joiner', from: Date.current) }

  describe 'GET /invitations/:token' do
    it 'redirects to registration with token when invitation is usable and user is not signed in' do
      get invitation_path(invitation.token)
      expect(response).to redirect_to(new_registration_path(invitation_token: invitation.token))
    end

    it 'redirects to sign in when token is unknown' do
      get invitation_path('invalid-token')
      expect(response).to redirect_to(new_session_path)
    end

    it 'shows ineligible page when invitation expired' do
      invitation.update_column(:created_at, (Invitation::EXPIRY + 1.day).ago)
      get invitation_path(invitation.token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('expired')
    end

    context 'when signed in with the invited email' do
      let(:user) { create(:user, email_address: invitation.email) }

      before do
        post session_path, params: { email_address: user.email_address, password: 'password123' }
      end

      it 'shows the accept invitation page' do
        get invitation_path(invitation.token)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('views.invitations.show.accept', locale: :en))
      end
    end

    context 'when signed in as a different user than the invitation email' do
      before do
        other = create(:user, email_address: 'other@example.com')
        post session_path, params: { email_address: other.email_address, password: 'password123' }
      end

      it 'shows the wrong-account message' do
        get invitation_path(invitation.token)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('join@example.com')
        expect(response.body).to include('other@example.com')
      end
    end
  end

  describe 'POST /invitations/:token/accept' do
    let(:user) { create(:user, email_address: invitation.email) }

    before do
      post session_path, params: { email_address: user.email_address, password: 'password123' }
    end

    it 'accepts the invitation and links the trainer' do
      expect do
        post accept_invitation_path(invitation.token)
      end.to change { invitation.reload.accepted_at }.from(nil).to(be_present)

      expect(user.reload.trainers).to include(trainer)
      expect(response).to redirect_to(root_path)
    end
  end
end
