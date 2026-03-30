# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trainers::InvitationsController, type: :controller do
  let(:trainer) { create(:trainer) }
  let(:trainer_user) { create(:user, trainer: trainer) }
  let(:slot) { create(:slot, trainer: trainer) }

  before do
    allow(controller).to receive(:require_authentication)
    allow(controller).to receive(:current_user).and_return(trainer_user)
    allow(controller).to receive(:authorize!).and_return(true)
    allow(controller).to receive(:authorize_trainer_portal!).and_return(true)
    allow(controller).to receive(:sync_session_trainer!).and_return(true)
  end

  describe 'POST #create' do
    it 'creates an invitation' do
      expect do
        post :create, params: {
          slot_id: slot.id,
          invitation: { email: 'brand_new@example.com', from: Date.current, name: 'Bob' }
        }
      end.to change(Invitation, :count).by(1)

      expect(response).to redirect_to(trainer_slot_path(slot))
    end

    it 'rejects when email already exists' do
      create(:user, email_address: 'taken@example.com')

      expect do
        post :create, params: {
          slot_id: slot.id,
          invitation: { email: 'taken@example.com', from: Date.current }
        }
      end.not_to change(Invitation, :count)

      expect(response).to redirect_to(trainer_slot_path(slot))
      expect(flash[:alert]).to be_present
    end
  end

  describe 'DELETE #destroy' do
    let!(:invitation) { create(:invitation, slot: slot, email: 'pending@example.com') }

    it 'removes a pending invitation' do
      expect do
        delete :destroy, params: { slot_id: slot.id, id: invitation.id }
      end.to change(Invitation, :count).by(-1)

      expect(response).to redirect_to(trainer_slot_path(slot))
    end
  end
end
