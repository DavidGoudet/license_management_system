require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:license_assignments).dependent(:destroy) }
    it { should have_many(:products).through(:subscriptions) }
  end

  describe 'dependent destroy' do
    let(:account) { create(:account) }
    let!(:user) { create(:user, account: account) }
    let!(:subscription) { create(:subscription, account: account) }
    let!(:license_assignment) { create(:license_assignment, account: account, user: user, product: subscription.product) }

    it 'destroys associated records when account is destroyed' do
      expect { account.destroy }.to change { User.count }.by(-1)
        .and change { Subscription.count }.by(-1)
        .and change { LicenseAssignment.count }.by(-1)
    end
  end
end
