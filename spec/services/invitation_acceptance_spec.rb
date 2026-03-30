# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvitationAcceptance do
  let(:trainer) { create(:trainer) }
  let(:slot) { create(:slot, trainer: trainer) }
  let(:invitation) { create(:invitation, slot: slot, email: 'accept@example.com', from: Date.current) }
  let(:user) { create(:user, email_address: 'accept@example.com') }

  it 'links trainer, creates regular attendee, and marks invitation accepted' do
    expect do
      described_class.call!(invitation: invitation, user: user)
    end.to change { invitation.reload.accepted_at }.from(nil).to(be_present)
      .and change(RegularAttendee, :count).by(1)

    expect(user.reload.trainers).to include(trainer)
  end
end
