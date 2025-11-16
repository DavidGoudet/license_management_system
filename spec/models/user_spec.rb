require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { should belong_to(:account) }
    it { should have_many(:license_assignments).dependent(:destroy) }
    it { should have_many(:products).through(:license_assignments) }
  end

  describe '#has_license_for?' do
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }
    let(:product) { create(:product) }
    let!(:subscription) { create(:subscription, account: account, product: product) }

    context 'when user has a license' do
      before do
        create(:license_assignment, account: account, user: user, product: product)
      end

      it 'returns true' do
        expect(user.has_license_for?(product)).to be true
      end
    end

    context 'when user does not have a license' do
      it 'returns false' do
        expect(user.has_license_for?(product)).to be false
      end
    end
  end

  describe '.without_product_license' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:subscription) { create(:subscription, account: account, product: product) }
    let(:user_with_license) { create(:user, account: account) }
    let(:user_without_license) { create(:user, account: account) }

    before do
      create(:license_assignment, account: account, user: user_with_license, product: product)
    end

    it 'returns users without the product license' do
      users = account.users.without_product_license(product.id)
      expect(users).to include(user_without_license)
      expect(users).not_to include(user_with_license)
    end
  end
end
