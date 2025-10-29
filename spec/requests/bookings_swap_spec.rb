require 'rails_helper'

RSpec.describe 'Booking Swap', type: :request do
  let(:user) { create(:user) }
  let(:slot1) { create(:slot) }
  let(:slot2) { create(:slot, day_of_week: 4, starts_at: '15:00:00', ends_at: '15:45:00') }
  let(:week_start) { Date.current.beginning_of_week + 1.week }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:authorize!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:require_authentication)
  end

  describe 'PATCH /bookings (swap from temporal booking)' do
    let!(:existing_booking) { create(:booking, user: user, slot: slot1, week_start: week_start) }

    it 'performs successful swap' do
      expect {
        patch booking_path(existing_booking), params: {
          slot_id: slot2.id
        }
      }.to change(Booking, :count).by(0) # No new booking created

      # Verify existing booking is updated
      existing_booking.reload
      expect(existing_booking.slot).to eq(slot2)
    end

    it 'returns success response' do
      patch booking_path(existing_booking), params: {
        slot_id: slot2.id
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(calendar_index_path(week: week_start))
    end

    it 'handles invalid booking_id' do
      patch booking_path(existing_booking), params: {
        slot_id: 99999
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /slots/:slot_id/bookings (swap from regular attendee)' do
    let!(:regular_attendee) { create(:regular_attendee, user: user, slot: slot1) }

    it 'performs successful swap' do
      expect {
        post slot_bookings_path(slot2), params: {
          week_start: week_start.to_s,
          cancelled_slot_id: slot1.id
        }
      }.to change(Booking, :count).by(1).and change(Cancellation, :count).by(1)

      # Verify new booking is created
      new_booking = Booking.find_by(user: user, slot: slot2, week_start: week_start)
      expect(new_booking).to be_present

      # Verify cancellation is created
      cancellation = Cancellation.find_by(user: user, slot: slot1, week_start: week_start)
      expect(cancellation).to be_present
    end

    it 'returns success response' do
      post slot_bookings_path(slot2), params: {
        week_start: week_start.to_s,
        cancelled_slot_id: slot1.id
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(calendar_index_path(week: week_start))
    end

    it 'handles invalid cancelled_slot_id' do
      post slot_bookings_path(slot2), params: {
        week_start: week_start.to_s,
        cancelled_slot_id: 99999
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /slots/:slot_id/bookings (regular booking)' do
    it 'creates regular booking when no swap parameters' do
      expect {
        post slot_bookings_path(slot1), params: { week_start: week_start.to_s }
      }.to change(Booking, :count).by(1)

      booking = Booking.find_by(user: user, slot: slot1, week_start: week_start)
      expect(booking).to be_present
    end
  end
end
