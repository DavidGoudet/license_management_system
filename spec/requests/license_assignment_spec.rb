require 'rails_helper'

RSpec.describe 'LicenseAssignments', type: :request do
  let(:account) { create(:account) }
  let!(:product) { create(:product) }
  let!(:user1) { create(:user, account: account) }
  let!(:user2) { create(:user, account: account) }
  let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 10) }

  describe 'GET /accounts/:account_id/license_assignments' do
    it 'returns successful response' do
      get account_license_assignments_path(account)
      expect(response).to have_http_status(:success)
    end

    it 'displays products with license counts' do
      get account_license_assignments_path(account)
      expect(response.body).to include(product.name)
      expect(response.body).to include('0/10')
    end

    it 'displays users' do
      get account_license_assignments_path(account)
      expect(response.body).to include(user1.name)
      expect(response.body).to include(user2.name)
    end

    context 'with existing assignments' do
      let!(:assignment) { create(:license_assignment, account: account, user: user1, product: product) }

      it 'shows used license count' do
        get account_license_assignments_path(account)
        expect(response.body).to include('1/10')
      end

      it 'displays current assignments table' do
        get account_license_assignments_path(account)
        expect(response.body).to include('Current Assignments')
        expect(response.body).to include(user1.name)
        expect(response.body).to include(product.name)
      end
    end

    context 'without subscriptions' do
      before { Subscription.destroy_all }

      it 'shows warning message' do
        get account_license_assignments_path(account)
        expect(response.body).to include('No Active Subscriptions')
      end
    end

    context 'without users' do
      before { User.destroy_all }

      it 'shows warning message' do
        get account_license_assignments_path(account)
        expect(response.body).to include('No Users')
      end
    end
  end

  describe 'POST /accounts/:account_id/license_assignments' do
    context 'with valid parameters' do
      it 'creates license assignments' do
        expect {
          post account_license_assignments_path(account), params: {
            product_ids: [ product.id ],
            user_ids: [ user1.id, user2.id ]
          }
        }.to change { LicenseAssignment.count }.by(2)
      end

      it 'redirects to index with success message' do
        post account_license_assignments_path(account), params: {
          product_ids: [ product.id ],
          user_ids: [ user1.id ]
        }
        expect(response).to redirect_to(account_license_assignments_path(account))
        follow_redirect!
        expect(response.body).to include('Successfully assigned 1 license')
      end
    end

    context 'with invalid parameters' do
      it 'renders index with error for no products' do
        post account_license_assignments_path(account), params: {
          product_ids: [],
          user_ids: [ user1.id ]
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Please select at least one product')
      end

      it 'renders index with error for no users' do
        post account_license_assignments_path(account), params: {
          product_ids: [ product.id ],
          user_ids: []
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Please select at least one user')
      end

      it 'renders index with error for insufficient licenses' do
        subscription.update(number_of_licenses: 1)

        post account_license_assignments_path(account), params: {
          product_ids: [ product.id ],
          user_ids: [ user1.id, user2.id ]
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Only 1 license(s) available')
      end
    end

    context 'with duplicate assignment' do
      before do
        create(:license_assignment, account: account, user: user1, product: product)
      end

      it 'skips duplicate and shows appropriate message' do
        post account_license_assignments_path(account), params: {
          product_ids: [ product.id ],
          user_ids: [ user1.id ]
        }
        expect(response).to redirect_to(account_license_assignments_path(account))
        follow_redirect!
        expect(response.body).to include('No licenses were assigned')
      end
    end
  end


  describe 'DELETE /accounts/:account_id/license_assignments/bulk_destroy' do
    let!(:assignment1) { create(:license_assignment, account: account, user: user1, product: product) }
    let!(:assignment2) { create(:license_assignment, account: account, user: user2, product: product) }

    context 'with valid assignment ids' do
      it 'destroys multiple assignments' do
        expect {
          delete bulk_destroy_account_license_assignments_path(account), params: {
            assignment_ids: [ assignment1.id, assignment2.id ]
          }
        }.to change { LicenseAssignment.count }.by(-2)
      end

      it 'redirects with success message' do
        delete bulk_destroy_account_license_assignments_path(account), params: {
          assignment_ids: [ assignment1.id ]
        }
        expect(response).to redirect_to(account_license_assignments_path(account))
        follow_redirect!
        expect(response.body).to include('Successfully removed 1 license')
      end
    end

    context 'with no assignment ids' do
      it 'redirects with error message' do
        delete bulk_destroy_account_license_assignments_path(account), params: {
          assignment_ids: []
        }
        expect(response).to redirect_to(account_license_assignments_path(account))
        follow_redirect!
        expect(response.body).to include('Please select at least one assignment')
      end
    end
  end
end
