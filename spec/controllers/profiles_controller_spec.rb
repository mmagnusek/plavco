require 'rails_helper'

RSpec.describe ProfilesController do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:require_authentication)
  end

  describe 'GET #edit' do
    it 'assigns the current user' do
      get :edit
      expect(assigns(:user)).to eq(user)
    end

    it 'renders the edit template' do
      get :edit
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:valid_params) { { user: { name: 'New Name', phone: '+420 123 456 789' } } }

      it 'updates the user' do
        patch :update, params: valid_params
        user.reload
        expect(user.name).to eq('New Name')
        expect(user.phone).to eq('+420123456789')
      end

      it 'redirects to root path' do
        patch :update, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('Profile updated successfully')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { user: { name: '', phone: '' } } }

      it 'does not update the user' do
        original_name = user.name
        patch :update, params: invalid_params
        user.reload
        expect(user.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end

      it 'does not set an alert message' do
        patch :update, params: invalid_params
        expect(flash[:alert]).to be_nil
      end
    end
  end
end
