# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'validations' do
    it 'is valid with required attributes' do
      invitation = build(:invitation)
      expect(invitation).to be_valid
    end

    it 'requires email' do
      invitation = build(:invitation, email: '')
      expect(invitation).not_to be_valid
    end
  end

  describe '#expired?' do
    it 'returns false when recent' do
      invitation = create(:invitation)
      expect(invitation.expired?).to be(false)
    end

    it 'returns true when older than EXPIRY' do
      invitation = create(:invitation)
      invitation.update_column(:created_at, (Invitation::EXPIRY + 1.day).ago)
      expect(invitation.expired?).to be(true)
    end
  end

  describe '#usable?' do
    it 'returns true for pending non-expired' do
      invitation = create(:invitation)
      expect(invitation.usable?).to be(true)
    end

    it 'returns false when accepted' do
      invitation = create(:invitation, accepted_at: Time.current)
      expect(invitation.usable?).to be(false)
    end

    it 'returns false when expired' do
      invitation = create(:invitation)
      invitation.update_column(:created_at, (Invitation::EXPIRY + 1.day).ago)
      expect(invitation.usable?).to be(false)
    end
  end
end
