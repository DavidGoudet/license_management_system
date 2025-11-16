require 'rails_helper'

RSpec.describe LicenseAssignment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:account_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:product_id) }

    describe 'uniqueness' do
      let(:account) { create(:account) }
      let(:user) { create(:user, account: account) }
      let(:product) { create(:product) }
      let!(:subscription) { create(:subscription, account: account, product: product) }
      let!(:existing_assignment) { create(:license_assignment, account: account, user: user, product: product) }

      it 'prevents duplicate assignments' do
        duplicate = build(:license_assignment, account: account, user: user, product: product)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('already has a license for this product')
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:account) }
    it { should belong_to(:user) }
    it { should belong_to(:product) }
  end

  describe 'custom validations' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let(:subscription) { create(:subscription, account: account, product: product) }
    let(:user) { create(:user, account: account) }

    describe 'user_belongs_to_account' do
      let(:other_account) { create(:account) }
      let(:other_user) { create(:user, account: other_account) }

      it 'is invalid if user does not belong to account' do
        assignment = build(:license_assignment, account: account, user: other_user, product: product)
        expect(assignment).not_to be_valid
        expect(assignment.errors[:user]).to include('must belong to the specified account')
      end
    end

    describe 'active_subscription_exists' do
      context 'with no subscription' do
        it 'is invalid' do
          assignment = build(:license_assignment, account: account, user: user, product: product)
          Subscription.destroy_all
          expect(assignment).not_to be_valid
          expect(assignment.errors[:base]).to include('No active subscription found for this product')
        end
      end

      context 'with expired subscription' do
        let!(:expired_subscription) { create(:subscription, :expired, account: account, product: product) }

        it 'is invalid' do
          Subscription.where.not(id: expired_subscription.id).destroy_all
          assignment = build(:license_assignment, account: account, user: user, product: product)
          expect(assignment).not_to be_valid
        end
      end
    end

    describe 'licenses_available' do
      let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 2) }
      let(:user1) { create(:user, account: account) }
      let(:user2) { create(:user, account: account) }
      let(:user3) { create(:user, account: account) }

      before do
        create(:license_assignment, account: account, user: user1, product: product)
        create(:license_assignment, account: account, user: user2, product: product)
      end

      it 'is invalid when no licenses available' do
        assignment = build(:license_assignment, account: account, user: user3, product: product)
        expect(assignment).not_to be_valid
        expect(assignment.errors[:base]).to include('No available licenses for this product')
      end
    end
  end
end
