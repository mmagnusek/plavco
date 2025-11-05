require 'rails_helper'

RSpec.describe RegularAttendee do
  let(:user) { create(:user) }
  let(:slot) { create(:slot) }

  # Helper dates for time ranges
  let(:jan_1) { Date.new(2025, 1, 1) }
  let(:feb_1) { Date.new(2025, 2, 1) }
  let(:mar_1) { Date.new(2025, 3, 1) }
  let(:apr_1) { Date.new(2025, 4, 1) }
  let(:may_1) { Date.new(2025, 5, 1) }

  describe '.within_time_range' do
    let(:user_from_and_to) { create(:user) }
    let(:user_from_only) { create(:user) }
    let(:user_before) { create(:user) }
    let(:user_after) { create(:user) }

    let!(:regular_attendee_from_and_to) { create(:regular_attendee, user: user_from_and_to, slot: slot, from: feb_1, to: mar_1) }
    let!(:regular_attendee_from_only) { create(:regular_attendee, user: user_from_only, slot: slot, from: feb_1, to: nil) }
    let!(:regular_attendee) { create(:regular_attendee, user: user, slot: slot, from: feb_1, to: nil) }
    let!(:regular_attendee_before) { create(:regular_attendee, user: user_before, slot: slot, from: jan_1, to: feb_1) }
    let!(:regular_attendee_after) { create(:regular_attendee, user: user_after, slot: slot, from: apr_1, to: may_1) }

    context 'when both from and to are provided' do
      it 'finds all records when query range fully contains all attendees' do
        expect(described_class.where(slot_id: slot.id).within_time_range(jan_1, apr_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before,
          regular_attendee_after
        )
      end

      it 'finds records that overlap with the query range' do
        # Query: [Feb 1, Mar 1] - should match attendees that overlap
        # regular_attendee_before ends at Feb 1, which equals query start, so it overlaps (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(feb_1, mar_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end

      it 'finds records that start before and end within the query range' do
        # Query: [Mar 1, Apr 1] - should match attendees that overlap with this range
        # regular_attendee_from_and_to ends at Mar 1, which equals query start, so it overlaps (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(mar_1, apr_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_after
        )
      end

      it 'does not find records that end before the query range starts' do
        # Query: [Mar 15, Apr 1] - should not match attendee_before (ends Feb 1), attendee_from_and_to (ends Mar 1), or attendee_to_only (ends Mar 1)
        mar_15 = Date.new(2025, 3, 15)
        expect(described_class.where(slot_id: slot.id).within_time_range(mar_15, apr_1)).to contain_exactly(
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_after
        )
      end

      it 'does not find records that start after the query range ends' do
        # Query: [Feb 1, Mar 1] - should not match attendee_after (starts Apr 1)
        # regular_attendee_before ends at Feb 1, which equals query start, so it overlaps (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(feb_1, mar_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end
    end

    context 'when only from is provided' do
      it 'finds records that have not ended before the start time' do
        # Query from: Feb 1 - should match all attendees that haven't ended before Feb 1
        # regular_attendee_before ends at Feb 1, which equals query start, so it matches (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(feb_1, nil)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before,
          regular_attendee_after
        )
      end

      it 'finds records with nil to (no end boundary)' do
        # Query from: Feb 1 - should match attendees with nil to
        # regular_attendee_before ends at Feb 1, which equals query start, so it matches (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(feb_1, nil)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before,
          regular_attendee_after
        )
      end

      it 'does not find records that end before the start time' do
        # Query from: Mar 1 - should not match attendee_before (ends Feb 1)
        # regular_attendee_from_and_to ends at Mar 1, which equals query start, so it matches (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(mar_1, nil)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_after
        )
      end
    end

    context 'when only to is provided' do
      it 'finds records that have not started after the end time' do
        # Query to: Mar 1 - should match all attendees that haven't started after Mar 1
        expect(described_class.where(slot_id: slot.id).within_time_range(nil, mar_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end

      it 'does not find records that start after the end time' do
        # Query to: Mar 1 - should not match attendee_after (starts Apr 1)
        expect(described_class.where(slot_id: slot.id).within_time_range(nil, mar_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end

      it 'finds records that start exactly at the end time' do
        # Query to: Feb 1 - should match attendees that start at or before Feb 1
        expect(described_class.where(slot_id: slot.id).within_time_range(nil, feb_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end
    end

    context 'when neither from nor to is provided' do
      it 'returns all records for the slot' do
        expect(described_class.where(slot_id: slot.id).within_time_range(nil, nil)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before,
          regular_attendee_after
        )
      end
    end

    context 'edge cases' do
      it 'handles exact boundary matches correctly' do
        # Query: [Feb 1, Mar 1] - exact match with attendee_from_and_to
        # regular_attendee_before ends at Feb 1, which equals query start, so it overlaps (>=)
        expect(described_class.where(slot_id: slot.id).within_time_range(feb_1, mar_1)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end

      it 'handles small date ranges correctly' do
        # Query: [Feb 1, Feb 2] - small range should match overlapping attendees
        # regular_attendee_before ends at Feb 1, which equals query start, so it overlaps (>=)
        feb_2 = Date.new(2025, 2, 2)
        expect(described_class.where(slot_id: slot.id).within_time_range(feb_1, feb_2)).to contain_exactly(
          regular_attendee_from_and_to,
          regular_attendee_from_only,
          regular_attendee,
          regular_attendee_before
        )
      end
    end
  end

  describe 'validations' do
    describe '#to_after_from' do
      it 'validates that to is after from when both are present' do
        attendee = build(:regular_attendee, user: user, slot: slot, from: feb_1, to: jan_1)
        expect(attendee).not_to be_valid
        expect(attendee.errors[:to]).to include('must be after from')
      end

      it 'allows nil to' do
        attendee = build(:regular_attendee, user: user, slot: slot, from: feb_1, to: nil)
        expect(attendee).to be_valid
      end

      it 'requires from' do
        attendee = build(:regular_attendee, user: user, slot: slot, from: nil, to: feb_1)
        expect(attendee).not_to be_valid
        expect(attendee.errors[:from]).to be_present
      end

      it 'does not allow to equal from' do
        attendee = build(:regular_attendee, user: user, slot: slot, from: feb_1, to: feb_1)
        expect(attendee).not_to be_valid
        expect(attendee.errors[:to]).to include('must be after from')
      end
    end

    describe '#uniqueness_of_regular_attendee' do
      let(:other_user) { create(:user) }
      let(:other_slot) { create(:slot, day_of_week: 2, starts_at: '10:00:00', ends_at: '10:45:00') }

      it 'prevents duplicate regular attendees for the same user and slot within the same time range' do
        create(:regular_attendee, user: user, slot: slot, from: jan_1, to: mar_1)
        duplicate = build(:regular_attendee, user: user, slot: slot, from: feb_1, to: apr_1)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to be_present
      end

      it 'allows different time ranges for the same user and slot' do
        create(:regular_attendee, user: user, slot: slot, from: jan_1, to: feb_1)
        different_range = build(:regular_attendee, user: user, slot: slot, from: mar_1, to: apr_1)

        expect(different_range).to be_valid
      end

      it 'allows the same user for different slots' do
        create(:regular_attendee, user: user, slot: slot, from: jan_1, to: mar_1)
        different_slot = build(:regular_attendee, user: user, slot: other_slot, from: jan_1, to: mar_1)

        expect(different_slot).to be_valid
      end

      it 'allows the same slot for different users' do
        create(:regular_attendee, user: user, slot: slot, from: jan_1, to: mar_1)
        different_user = build(:regular_attendee, user: other_user, slot: slot, from: jan_1, to: mar_1)

        expect(different_user).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:slot) }
  end
end
