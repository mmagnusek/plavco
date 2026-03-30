# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations' do
  describe 'GET /register' do
    it 'shows the registration form' do
      get new_registration_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create account')
    end
  end

  describe 'POST /registration' do
    context 'without invitation' do
      it 'creates a user and signs in' do
        expect do
          post registration_path, params: {
            user: {
              email_address: 'newuser@example.com',
              name: 'New User',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end.to change(User, :count).by(1)

        expect(response).to redirect_to(root_path)
        expect(User.find_by(email_address: 'newuser@example.com')).to be_present
      end

      it 'rejects duplicate email' do
        create(:user, email_address: 'taken@example.com')

        expect do
          post registration_path, params: {
            user: {
              email_address: 'taken@example.com',
              name: 'Someone',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with invitation' do
      let(:trainer) { create(:trainer) }
      let(:slot) { create(:slot, trainer: trainer) }
      let(:invitation) { create(:invitation, slot: slot, email: 'join@example.com', name: 'Joiner', from: Date.current) }

      it 'creates user, regular attendee, and marks invitation accepted' do
        expect do
          post registration_path, params: {
            invitation_token: invitation.token,
            user: {
              name: 'Joiner Name',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end.to change(User, :count).by(1)
          .and change(RegularAttendee, :count).by(1)

        invitation.reload
        expect(invitation.accepted_at).to be_present

        user = User.find_by(email_address: 'join@example.com')
        expect(user.trainers).to include(trainer)
        expect(response).to redirect_to(root_path)
      end

      it 'rejects expired invitations' do
        invitation.update_column(:created_at, (Invitation::EXPIRY + 1.day).ago)

        expect do
          post registration_path, params: {
            invitation_token: invitation.token,
            user: {
              name: 'Joiner Name',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end.not_to change(User, :count)

        expect(response).to redirect_to(invitation_path(invitation.token))
      end
    end
  end
end
