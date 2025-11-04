require 'rails_helper'

RSpec.describe Slot do
  describe 'validations' do
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:max_participants) }
    it { should validate_presence_of(:day_of_week) }
    it { should validate_numericality_of(:max_participants).is_greater_than(0).is_less_than_or_equal_to(20) }
    it { should validate_inclusion_of(:day_of_week).in_range(1..5) }
  end

  describe 'associations' do
    it { should have_many(:bookings).dependent(:destroy) }
    it { should have_many(:cancellations).dependent(:destroy) }
    it { should have_many(:regular_attendees).dependent(:destroy) }
    it { should have_many(:users).through(:bookings) }
  end

  describe '#available_spots_for_week' do
    let(:slot) { create(:slot, max_participants: 5) }
    let(:week_start) { Date.current.beginning_of_week }

    it 'returns the full capacity when no bookings exist' do
      expect(slot.available_spots_for_week(week_start)).to eq(5)
    end
  end

  describe '#start_time' do
    let(:slot) { create(:slot, day_of_week: 3, starts_at: '08:00:00', ends_at: '08:45:00') }
    let(:week_start) { Date.parse('2025-10-27').beginning_of_week }

    it 'returns the start time' do
      expect(slot.start_time(week_start)).to eq(Time.zone.parse('2025-10-29 08:00:00'))
    end
  end

  describe '#last_possible_modification_at' do
    let(:slot) { create(:slot, day_of_week: 3, starts_at: '08:00:00', ends_at: '08:45:00') }
    let(:week_start) { Date.parse('2025-10-27').beginning_of_week }

    it 'returns the last possible modification at' do
      expect(slot.last_possible_modification_at(week_start)).to eq(Time.zone.parse('2025-10-28 17:00:00'))
    end
  end

  describe '#fully_booked_for_week?' do
    let(:slot) { create(:slot, max_participants: 3) }
    let(:week_start) { Date.current.beginning_of_week }

    it 'returns false when slot has available spots' do
      expect(slot.fully_booked_for_week?(week_start)).to be false
    end
  end

  describe '#duration_minutes' do
    let(:slot) { create(:slot, starts_at: '10:00:00', ends_at: '10:45:00') }

    it 'returns the duration in minutes' do
      expect(slot.duration_minutes).to eq(45)
    end
  end
end
