require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe 'associations' do
    it { should have_many(:subscriptions) }
    it { should have_many(:license_assignments) }
    it { should have_many(:accounts).through(:subscriptions) }
  end
end
