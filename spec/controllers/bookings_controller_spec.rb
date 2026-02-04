require 'rails_helper'

RSpec.describe BookingsController do
  let(:user) { create(:user) }
  let(:slot1) { create(:slot, trainer: trainer) }
  let(:slot2) { create(:slot, day_of_week: 4, starts_at: '15:00:00', ends_at: '15:45:00', trainer: trainer) }
  let(:week_start) { Date.current.beginning_of_week + 1.week }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authorize!).and_return(true)
    allow(controller).to receive(:require_authentication)
  end

  describe 'POST #create' do
    context 'with regular booking' do
      it 'creates a new booking' do
        expect {
          post :create, params: { slot_id: slot1.id, week_start: week_start.to_s }
        }.to change(Booking, :count).by(1)
      end

      it 'redirects with success message' do
        post :create, params: { slot_id: slot1.id, week_start: week_start.to_s }
        expect(response).to redirect_to(calendar_index_path(week: week_start))
        expect(flash[:notice]).to eq('Booking created successfully.')
      end
    end

    context 'with swap from temporal booking' do
      let!(:existing_booking) { create(:booking, user: user, slot: slot1, week_start: week_start) }

      it 'updates existing booking instead of creating new one' do
        expect {
          post :update, params: {
            slot_id: slot2.id,
            id: existing_booking.id
          }
        }.to change(Booking, :count).by(0) # No new booking created
      end

      it 'updates the existing booking slot' do
        post :update, params: {
          slot_id: slot2.id,
          id: existing_booking.id
        }
        existing_booking.reload
        expect(existing_booking.slot).to eq(slot2)
      end

      it 'redirects with swap success message' do
        post :update, params: {
          slot_id: slot2.id,
          id: existing_booking.id
        }
        expect(response).to redirect_to(calendar_index_path(week: week_start))
        expect(flash[:notice]).to include('Successfully swapped.')
      end
    end

    context 'with swap from regular attendee slot' do
      let!(:regular_attendee) { create(:regular_attendee, user: user, slot: slot1) }

      it 'creates new booking and cancellation' do
        expect {
          post :create, params: {
            slot_id: slot2.id,
            week_start: week_start.to_s,
            cancelled_slot_id: slot1.id
          }
        }.to change(Booking, :count).by(1).and change(Cancellation, :count).by(1)
      end

      it 'creates cancellation for the cancelled slot' do
        post :create, params: {
          slot_id: slot2.id,
          week_start: week_start.to_s,
          cancelled_slot_id: slot1.id
        }

        cancellation = Cancellation.find_by(user: user, slot: slot1, week_start: week_start)
        expect(cancellation).to be_present
      end

      it 'creates booking with reference to cancellation' do
        post :create, params: {
          slot_id: slot2.id,
          week_start: week_start.to_s,
          cancelled_slot_id: slot1.id
        }

        booking = Booking.find_by(user: user, slot: slot2, week_start: week_start)
        cancellation = Cancellation.find_by(user: user, slot: slot1, week_start: week_start)
        expect(booking.cancelled_from).to eq(cancellation)
      end

      it 'redirects with swap success message' do
        post :create, params: {
          slot_id: slot2.id,
          week_start: week_start.to_s,
          cancelled_slot_id: slot1.id
        }
        expect(response).to redirect_to(calendar_index_path(week: week_start))
        expect(flash[:notice]).to include('Booking created successfully.')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:booking) { create(:booking, user: user, slot: slot1, week_start: week_start) }

    it 'destroys the booking' do
      expect {
        delete :destroy, params: { id: booking.id, slot_id: slot1.id }
      }.to change(Booking, :count).by(-1)
    end

    it 'redirects with success message' do
      delete :destroy, params: { id: booking.id, slot_id: slot1.id }
      expect(response).to redirect_to(calendar_index_path(week: week_start))
      expect(flash[:notice]).to eq('Booking removed successfully.')
    end
  end
end
