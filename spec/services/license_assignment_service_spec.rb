require 'rails_helper'

RSpec.describe LicenseAssignmentService do
  let(:account) { create(:account) }
  let(:product1) { create(:product, name: 'Product 1') }
  let(:product2) { create(:product, name: 'Product 2') }
  let(:user1) { create(:user, account: account, name: 'User 1') }
  let(:user2) { create(:user, account: account, name: 'User 2') }
  let!(:subscription1) { create(:subscription, account: account, product: product1, number_of_licenses: 5) }
  let!(:subscription2) { create(:subscription, account: account, product: product2, number_of_licenses: 3) }
  let(:service) { described_class.new(account) }

  describe '#bulk_assign' do
    context 'with valid inputs' do
      it 'creates license assignments' do
        expect {
          service.bulk_assign(
            product_ids: [ product1.id ],
            user_ids: [ user1.id, user2.id ]
          )
        }.to change { LicenseAssignment.count }.by(2)
      end

      it 'returns success result' do
        result = service.bulk_assign(
          product_ids: [ product1.id ],
          user_ids: [ user1.id ]
        )

        expect(result[:success]).to be true
        expect(result[:assignments].count).to eq(1)
        expect(result[:message]).to eq('Successfully assigned 1 license(s)')
      end

      it 'assigns multiple products to multiple users' do
        result = service.bulk_assign(
          product_ids: [ product1.id, product2.id ],
          user_ids: [ user1.id, user2.id ]
        )

        expect(result[:success]).to be true
        expect(result[:assignments].count).to eq(4)
        expect(LicenseAssignment.count).to eq(4)
      end
    end

    context 'with no products selected' do
      it 'returns error' do
        result = service.bulk_assign(
          product_ids: [],
          user_ids: [ user1.id ]
        )

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Please select at least one product')
      end
    end

    context 'with no users selected' do
      it 'returns error' do
        result = service.bulk_assign(
          product_ids: [ product1.id ],
          user_ids: []
        )

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Please select at least one user')
      end
    end

    context 'when user already has license' do
      before do
        create(:license_assignment, account: account, user: user1, product: product1)
      end

      it 'skips duplicate assignment' do
        result = service.bulk_assign(
          product_ids: [ product1.id ],
          user_ids: [ user1.id ]
        )

        expect(result[:success]).to be true
        expect(result[:assignments]).to be_empty
        expect(result[:message]).to eq('No licenses were assigned - all selected users already have the selected products')
      end

      it 'only assigns to users without license' do
        result = service.bulk_assign(
          product_ids: [ product1.id ],
          user_ids: [ user1.id, user2.id ]
        )

        expect(result[:success]).to be true
        expect(result[:assignments].count).to eq(1)
        expect(result[:assignments].first.user).to eq(user2)
      end
    end

    context 'when insufficient licenses available' do
      let!(:subscription) { create(:subscription, account: account, product: product1, number_of_licenses: 1) }
      let(:user3) { create(:user, account: account) }

      before do
        Subscription.where.not(id: subscription.id).where(product: product1).destroy_all
      end

      it 'returns error' do
        result = service.bulk_assign(
          product_ids: [ product1.id ],
          user_ids: [ user1.id, user2.id ]
        )

        expect(result[:success]).to be false
        expect(result[:message]).to include('Only 1 license(s) available')
        expect(LicenseAssignment.count).to eq(0)
      end
    end

    context 'with invalid product ids' do
      it 'returns error' do
        result = service.bulk_assign(
          product_ids: [ 99999 ],
          user_ids: [ user1.id ]
        )

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Invalid products selected')
      end
    end

    context 'with invalid user ids' do
      it 'returns error' do
        result = service.bulk_assign(
          product_ids: [ product1.id ],
          user_ids: [ 99999 ]
        )

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Invalid users selected')
      end
    end

    context 'transaction rollback' do
      it 'rolls back all assignments on error' do
        # Create a situation that will fail on the second assignment
        allow_any_instance_of(LicenseAssignment).to receive(:save!).and_call_original
        allow_any_instance_of(LicenseAssignment).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(LicenseAssignment.new))

        expect {
          service.bulk_assign(
            product_ids: [ product1.id ],
            user_ids: [ user1.id, user2.id ]
          )
        }.not_to change { LicenseAssignment.count }
      end
    end
  end

  describe '#bulk_unassign' do
    let!(:assignment1) { create(:license_assignment, account: account, user: user1, product: product1) }
    let!(:assignment2) { create(:license_assignment, account: account, user: user2, product: product1) }

    context 'with valid assignment ids' do
      it 'removes license assignments' do
        expect {
          service.bulk_unassign(assignment_ids: [ assignment1.id, assignment2.id ])
        }.to change { LicenseAssignment.count }.by(-2)
      end

      it 'returns success result' do
        result = service.bulk_unassign(assignment_ids: [ assignment1.id ])

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Successfully removed 1 license(s)')
      end
    end

    context 'with no assignment ids' do
      it 'returns error' do
        result = service.bulk_unassign(assignment_ids: [])

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Please select at least one assignment')
      end
    end

    context 'with invalid assignment ids' do
      it 'returns success with no removals' do
        result = service.bulk_unassign(assignment_ids: [ 99999 ])

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Successfully removed 0 license(s)')
      end
    end

    context 'only removes assignments from current account' do
      let(:other_account) { create(:account) }
      let(:other_user) { create(:user, account: other_account) }
      let!(:subscription) { create(:subscription, account: other_account, product: product1, number_of_licenses: 1) }
      let!(:other_assignment) { create(:license_assignment, account: other_account, user: other_user, product: product1) }

      it 'does not remove assignments from other accounts' do
        expect {
          service.bulk_unassign(assignment_ids: [ other_assignment.id ])
        }.not_to change { LicenseAssignment.count }
      end
    end
  end
end
