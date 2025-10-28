require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:require_authentication)
  end

  describe 'GET /profile/edit' do
    it 'returns http success' do
      get edit_profile_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /profile' do
    context 'with valid parameters' do
      let(:valid_params) { { user: { name: 'Updated Name', phone: '+420 987 654 321' } } }

      it 'updates the user profile' do
        patch profile_path, params: valid_params
        user.reload
        expect(user.name).to eq('Updated Name')
        expect(user.phone).to eq('+420987654321')
      end

      it 'redirects to root path' do
        patch profile_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { user: { name: '', phone: 'invalid' } } }

      it 'does not update the user profile' do
        original_name = user.name
        patch profile_path, params: invalid_params
        user.reload
        expect(user.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch profile_path, params: invalid_params
        expect(response).to render_template(:edit)
      end
    end
  end
end
