require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:number_of_licenses) }
    it { should validate_presence_of(:issued_at) }
    it { should validate_presence_of(:expires_at) }
    it { should validate_numericality_of(:number_of_licenses).is_greater_than(0).only_integer }

    describe 'expires_at_after_issued_at' do
      it 'is invalid if expires_at is before issued_at' do
        subscription = build(:subscription, issued_at: Time.current, expires_at: 1.day.ago)
        expect(subscription).not_to be_valid
        expect(subscription.errors[:expires_at]).to include('must be after issued date')
      end

      it 'is valid if expires_at is after issued_at' do
        subscription = build(:subscription, issued_at: Time.current, expires_at: 1.year.from_now)
        expect(subscription).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:account) }
    it { should belong_to(:product) }
  end

  describe 'scopes' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:active_subscription) { create(:subscription, account: account, product: product) }
    let!(:expired_subscription) { create(:subscription, :expired, account: account, product: product) }

    describe '.active' do
      it 'returns only active subscriptions' do
        expect(Subscription.active).to include(active_subscription)
        expect(Subscription.active).not_to include(expired_subscription)
      end
    end

    describe '.for_account_and_product' do
      it 'returns subscriptions for specific account and product' do
        subscriptions = Subscription.for_account_and_product(account.id, product.id)
        expect(subscriptions).to include(active_subscription, expired_subscription)
      end
    end
  end

  describe '#active?' do
    context 'when subscription has not expired' do
      let(:subscription) { create(:subscription) }

      it 'returns true' do
        expect(subscription.active?).to be true
      end
    end

    context 'when subscription has expired' do
      let(:subscription) { create(:subscription, :expired) }

      it 'returns false' do
        expect(subscription.active?).to be false
      end
    end
  end

  describe '#remaining_licenses' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 5) }

    context 'with no assignments' do
      it 'returns total licenses' do
        expect(subscription.remaining_licenses).to eq(5)
      end
    end

    context 'with some assignments' do
      let!(:user1) { create(:user, account: account) }
      let!(:user2) { create(:user, account: account) }

      before do
        create(:license_assignment, account: account, user: user1, product: product)
        create(:license_assignment, account: account, user: user2, product: product)
      end

      it 'returns remaining licenses' do
        expect(subscription.remaining_licenses).to eq(3)
      end
    end

    context 'when subscription is expired' do
      let(:subscription) { create(:subscription, :expired, account: account, product: product) }

      it 'returns 0' do
        expect(subscription.remaining_licenses).to eq(0)
      end
    end
  end

  describe '#used_licenses_count' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:subscription) { create(:subscription, account: account, product: product) }
    let!(:user1) { create(:user, account: account) }
    let!(:user2) { create(:user, account: account) }

    before do
      create(:license_assignment, account: account, user: user1, product: product)
      create(:license_assignment, account: account, user: user2, product: product)
    end

    it 'returns count of used licenses' do
      expect(subscription.used_licenses_count).to eq(2)
    end
  end

  describe '.total_licenses_for' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:subscription1) { create(:subscription, account: account, product: product, number_of_licenses: 5) }
    let!(:subscription2) { create(:subscription, account: account, product: product, number_of_licenses: 3) }

    it 'sums all active licenses for account and product' do
      expect(Subscription.total_licenses_for(account.id, product.id)).to eq(8)
    end

    context 'with expired subscription' do
      let!(:expired_sub) { create(:subscription, :expired, account: account, product: product, number_of_licenses: 10) }

      it 'does not include expired subscriptions' do
        expect(Subscription.total_licenses_for(account.id, product.id)).to eq(8)
      end
    end
  end
end
