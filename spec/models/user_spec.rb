require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email_address) }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
  end

  describe 'associations' do
    it { should have_many(:bookings).dependent(:destroy) }
    it { should have_many(:cancellations).dependent(:destroy) }
    it { should have_many(:regular_attendees).dependent(:destroy) }
    it { should have_many(:omni_auth_identities).dependent(:destroy) }
    it { should have_many(:sessions).dependent(:destroy) }
  end

  describe '#complete_profile?' do
    it 'returns true when user has phone' do
      user = create(:user, phone: '+420123456789')
      expect(user.complete_profile?).to be true
    end

    it 'returns false when user has no phone' do
      user = build(:user, phone: '')
      user.save(validate: false)
      expect(user.complete_profile?).to be false
    end
  end

  describe '#full_name' do
    it 'returns the user name' do
      user = create(:user, name: 'John Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#active_bookings' do
    let(:user) { create(:user) }

    it 'returns an ActiveRecord relation' do
      expect(user.active_bookings).to be_a(ActiveRecord::Relation)
    end
  end
end
